/*
 * Copyright (c) 2004, 2005  Andrei Vasiliu
 * 
 * 
 * This file is part of MudBot.
 * 
 * MudBot is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * MudBot is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with MudBot; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 */


/* Main source file, handles sockets, signals and other little things. */

/* -= STACK FLOW =-

main
\
 \ - modules_register
 |   \
 |    \ - read_config
 |    |
 |    \ - load_builtin_modules
 |
 \ - module_init_data
 |
 \ - module_main_loop
 |
 \ - main_loop

main_loop
\
 \ - check_timers
 |
 \ - control.in
 |   \
 |    \ - new_descriptor
 |
 \ - client.in
 |   \
 |    \ - process_client
 |        \
 |         \ - log_bytes
 |         |
 |         \ - process_client_line
 |             \
 |              \ - module_process_client_aliases
 |              |
 |              \ - send_to_server
 |
 \ - client.out
 |
 \ - client.exc
 |
 \ - server.in
 |   \
 |    \ - process_server
 |        \
 |         \ - mccp_decompress
 |             \
 |              \ - process_buffer
 |      	    \
 |                   \ - log_bytes
 |                   |
 |      	     \ - server_telnet
 |                   |   \
 |                   |    \ - module_mxp_enabled
 |                   |    |
 |                   |    \ - handle_atcp
 |      	     |
 |      	     \ - module_process_server_line
 |      	     |
 |      	     \ - module_process_server_prompt
 |      	     |
 |      	     \ - print_line/clean_line
 |
 \ - server.exc
 |
... (module descriptors)

*/


#define MAIN_ID "$Name:  $ $Id: main.c,v 3.12 2006/12/19 18:39:19 andreivasiliu Exp $"

#include <unistd.h>	/* For write(), read() */
#include <stdarg.h>	/* For variable argument functions */
#include <signal.h>	/* For signal() */
#include <time.h>	/* For time() */
#include <sys/stat.h>	/* For stat() */
#include <fcntl.h>	/* For fcntl() */

#include "header.h"

/* Portability stuff. */
#if defined( FOR_WINDOWS )
# include <winsock2.h>    /* All winsock2 stuff. */
# if !defined( DISABLE_MCCP )
#  include <zlib.h>  /* needed for MCCP */
# endif
#else
# include <sys/socket.h>  /* All socket stuff */
# include <sys/time.h>    /* For gettimeofday() */ 
# include <netdb.h>       /* For gethostbyaddr() and others */
# include <netinet/in.h>  /* For sockaddr_in */
# include <arpa/inet.h>   /* For addr_aton */
# include <dlfcn.h>	  /* For dlopen(), dlsym(), dlclose() and dlerror() */
# if !defined( DISABLE_MCCP )
#  include <zlib.h>	  /* needed for MCCP */
# endif
#endif

int main_version_major = 2;
int main_version_minor = 5;



char *main_id = MAIN_ID "\r\n" HEADER_ID "\r\n";
#if defined( FOR_WINDOWS )
extern char *winmain_id;
#endif

/*** Functions used by modules. ***/

#ifndef __attribute__
# define __attribute__( params ) ;
#endif


/* Line operators. */
void prefix( char *string );
void suffix( char *string );
void replace( char *string );
void insert( int pos, char *string );
void prefixf( char *string, ... ) __attribute__ ( ( format( printf, 1, 2 ) ) );
void suffixf( char *string, ... ) __attribute__ ( ( format( printf, 1, 2 ) ) );

/* Communication */
MODULE *get_modules( );
void DEBUG( char * );
void debugf( char *string, ... ) __attribute__ ( ( format( printf, 1, 2 ) ) );
void debugerr( char *string );
void logff( char *type, char *string, ... ) __attribute__ ( ( format( printf, 2, 3 ) ) );
void clientf( char *string );
void clientfr( char *string );
void clientff( char *string, ... ) __attribute__ ( ( format( printf, 1, 2 ) ) );
void send_to_server( char *string );
void show_prompt( );
void mxp( char *string, ... ) __attribute__ ( ( format( printf, 1, 2 ) ) );
int mxp_tag( int tag );
int mxp_stag( int tag, char *dest );

/* Utility */
#if defined( FOR_WINDOWS )
int gettimeofday( struct timeval *tv, void * );
#endif
char *get_string( const char *argument, char *arg_first, int max );
int cmp( char *trigger, char *string );
void extract_wildcard( int nr, char *dest, int max );

/* Timers */
TIMER *get_timers( );
int get_timer( );
TIMER *add_timer( const char *name, float delay, void (*cb)( TIMER *self ), int d0, int d1, int d2 );
void del_timer( const char *name );

/* Networking */
DESCRIPTOR *get_descriptors( );
int mb_connect( char *hostname, int port );
char *get_connect_error( );
void add_descriptor( DESCRIPTOR *desc );
void remove_descriptor( DESCRIPTOR *desc );
int c_read( int fd, void *buf, size_t count );
int c_write( int fd, const void *buf, size_t count );
int c_close( int fd );



/*** Built-in modules. ***/

#if defined( FOR_WINDOWS )
/* Imperian module. */
void imperian_module_register( );

/* Imperian Mapper module. */
void i_mapper_module_register( );

/* Imperian offensive module. */
void offensive_module_register( );

/* MudMaster Chat module. */
void mmchat_module_register( );

/* Gtk GUI module. */
void gui_module_register( );

/* Imperian Voter module. */
void voter_module_register( );
#endif



/*** Global variables. ***/

#if !defined( DISABLE_MCCP )
/* zLib - MCCP */
z_stream *zstream;
#endif
int compressed;

const char iac_sb[] = { IAC, SB, 0 };
const char iac_se[] = { IAC, SE, 0 };

/* The three magickal numbers. */
DESCRIPTOR *control;
DESCRIPTOR *client;
DESCRIPTOR *server;

DESCRIPTOR *current_descriptor;

LINE *current_new_line;

char exec_file[1024];

int default_listen_port = 123;

int copyover;

int bytes_sent;
int bytes_received;
int bytes_uncompressed;

/* Pre-allocated dynamic buffers, that will be grown/shrinked.
 * This is to prevent the many free() and alloc() calls. */
char *prefix_buffer, *prefix_p, *prefix_max;
char *suffix_buffer, *suffix_p, *suffix_max;
char *replace_buffer, *replace_p, *replace_max;
/* A few more buffers are local static variables. */

/* Info that may be useful on a crash. */
char *mb_section = "Initializing";
char *mod_section = NULL;
MODULE *current_mod;
char *desc_name;
char *desc_section;
char *crash_buffer;
int crash_buffer_len;
LINE *crash_line;

/* Misc. */
char buffer_noclient[65536];
char buffer_data[65536], *g_b = buffer_data;
const char *g_blimit = buffer_data + 16384;
char send_buffer[65536];
int buffer_output;
int buffer_send_to_server;
int safe_mode;
int last_timer;
int sent_something;
int current_line;
int show_processing_time;
int unable_to_write;
char *buffer_write_error;
char *initial_big_buffer;
int bw_end_offset;
int bind_to_localhost;
int disable_mccp;
int verbose_mccp;
int mxp_enabled;
int clientf_modifies_suffix;
int add_newline;
int show_prompt_again;
int processing;
LINE last_prompt;
char *wildcards[16][2];
int wildcard_limit;

char *connection_error;

int logging;
char *log_file = "log.txt";

char server_hostname[1024];
char client_hostname[1024];

/* Options from config.txt */
char default_host[512];
int default_port;
char *proxy_host;
int proxy_port;
char proxy_type[512];
int default_port;
char atcp_login_as[512];
char default_user[512];
char default_pass[512];
int default_mxp_mode = 7;
int strip_telnet_ga;

/* ATCP. */
int a_hp, a_mana, a_end, a_will, a_exp;
int a_max_hp, a_max_mana, a_max_end, a_max_will;
char a_name[512], a_title[512];
int a_on;


void clientfb( char *string );
void unlink_timer( TIMER *timer );
void free_timer( TIMER *timer );


/* Shared memory. */

void share_memory( char *name, void *pointer, int size );
void shared_memory_is_pointer_to_string( char *name );
void update_shared_memory( MODULE *module );
void remove_shared_memory_by_module( MODULE *module );

struct shared_memory_data
{
   char *name;
   char *pointer;
   int size;
   
   short pointer_to_string;
   
   MODULE *module;
   
   struct shared_memory_data *next;
} *shared_memory_table;


/* Contains the name of the currently running function. */
char *debug[6];

/* Contains all registered timers, that will need to go off. */
TIMER *timers;

/* Contains all sockets and descriptors, including server, client, control. */
DESCRIPTOR *descs;

/* Module table. */
MODULE *modules;

MODULE built_in_modules[] =
{
   /* Imperian healing system. */
//     { "Imperian", imperian_module_register, NULL },
   
   /* Imperian offensive system. */
//     { "IOffense", offensive_module_register, NULL },
   
   /* Imperian Automapper. */
//     { "IMapper", i_mapper_module_register, NULL },
   
   /* MudMaster Chat module. */
//     { "MMChat", mmchat_module_register, NULL },
   
   /* Gtk GUI. */
//     { "GUI", gui_module_register, NULL },
   
   /* Imperian Voter module. */
//     { "Voter", voter_module_register, NULL },
   
     { NULL }
};


void log_write( int s, char *string, int bytes )
{
   void log_bytes( char *type, char *string, int bytes );
   
   if ( !logging )
     return;
   
   if ( !s )
     return;
   
   if ( client && s == client->fd )
     log_bytes( "m->c", string, bytes );
   else if ( server && s == server->fd )
     log_bytes( "m->s", string, bytes );
}


#if defined( FOR_WINDOWS )
int c_read( int fd, void *buf, size_t count )
{
   return recv( fd, buf, count, 0 );
}
int c_write( int fd, const void *buf, size_t count )
{
   log_write( fd, (char *) buf, count );
   
   return send( fd, buf, count, 0 );
}
int c_close( int fd )
{
   return shutdown( fd, 2 /*SHUT_RDWR*/ );
}
#else
int c_read( int fd, void *buf, size_t count )
{
   return (int) read( fd, buf, count );
}
int c_write( int fd, const void *buf, size_t count )
{
   log_write( fd, (char *) buf, count );
   
   return (int) write( fd, buf, count );
}
int c_close( int fd )
{
   return close( fd );
}
#endif


void *get_variable( char *name )
{
   struct {
      char *name;
      void *var;
   } variables[ ] =
     {
	/* ATCP */
	  { "a_on", &a_on },
	  { "a_hp", &a_hp },
	  { "a_max_hp", &a_max_hp },
	  { "a_mana", &a_mana },
	  { "a_max_mana", &a_max_mana },
	  { "a_end", &a_end },
	  { "a_max_end", &a_max_end },
	  { "a_will", &a_will },
	  { "a_max_will", &a_max_will },
	  { "a_exp", &a_exp },
	  { "a_name", a_name },
	  { "a_title", a_title },
	
	  { NULL, NULL }
     }, *p;
   
   for ( p = variables; p->name; p++ )
     if ( !strcmp( p->name, name ) )
       return p->var;
   
   debugf( "Unable to serve the module with variable '%s'!", name );
   
   return NULL;
}


void *get_function( char *name )
{
   struct {
      char *name;
      void *func;
   } functions[ ] =
     {
	/* Line operators. */
	  { "prefix", prefix },
	  { "suffix", suffix },
	  { "replace", replace },
	  { "insert", insert },
	  { "prefixf", prefixf },
	  { "suffixf", suffixf },
	/* Communication */
	  { "get_variable", get_variable },
	  { "get_modules", get_modules },
	  { "DEBUG", DEBUG },
	  { "debugf", debugf },
	  { "debugerr", debugerr },
	  { "logff", logff },
	  { "clientf", clientf  },
	  { "clientfr", clientfr },
	  { "clientff", clientff },
	  { "send_to_server", send_to_server },
	  { "show_prompt", show_prompt },
	  { "mxp", mxp },
	  { "mxp_tag", mxp_tag },
	  { "mxp_stag", mxp_stag },
	  { "share_memory", share_memory },
	  { "shared_memory_is_pointer_to_string", shared_memory_is_pointer_to_string },
	/* Utility */
	  { "gettimeofday", gettimeofday },
	  { "get_string", get_string },
	  { "cmp", cmp },
	  { "extract_wildcard", extract_wildcard },
	/* Timers */
	  { "get_timers", get_timers },
	  { "get_timer", get_timer },
	  { "add_timer", add_timer },
	  { "del_timer", del_timer },
	/* Networking */
	  { "get_descriptors", get_descriptors },
	  { "mb_connect", mb_connect },
	  { "get_connect_error", get_connect_error },
	  { "add_descriptor", add_descriptor },
	  { "remove_descriptor", remove_descriptor },
	  { "c_read", c_read },
	  { "c_write", c_write },
	  { "c_close", c_close },
	
	  { NULL, NULL }
     }, *p;
   
   for ( p = functions; p->name; p++ )
     if ( !strcmp( p->name, name ) )
       return p->func;
   
   debugf( "Unable to serve the module with function '%s'!", name );
   
   return NULL;
}


#if !defined( FOR_WINDOWS )
/* Replacement for printf. Also located in winmain.c, if that is used. */
void debugf( char *string, ... )
{
   MODULE *module;
   char buf [ 4096 ];
   int to_stdout = 1;
   
   va_list args;
   va_start( args, string );
   vsnprintf( buf, 4096, string, args );
   va_end( args );
   
   /* Check if any module wants to display it anywhere else. */
   for ( module = modules; module; module = module->next )
     {
	if ( module->debugf )
	  {
	     (*module->debugf)( buf );
	     to_stdout = 0;
	  }
     }
   
   if ( to_stdout )
     printf( "%s\n", buf );
   
   if ( logging )
     logff( "debug", buf );
}
#endif

/* Replacement for perror. */
void debugerr( char *string )
{
   debugf( "%s: %s", string, strerror( errno ) );
}


/* It was initially a macro. That's why. */
void DEBUG( char *str )
{
   debug[5] = debug[4];
   debug[4] = debug[3];
   debug[3] = debug[2];
   debug[2] = debug[1];
   debug[1] = debug[0];
   debug[0] = str;
}



MODULE *get_modules( )
{
   return modules;
}

DESCRIPTOR *get_descriptors( )
{
   return descs;
}

TIMER *get_timers( )
{
   return timers;
}


MODULE *add_module( )
{
   MODULE *module, *m;
   
   module = calloc( 1, sizeof( MODULE ) );
   
   /* Link it. */
   if ( !modules )
     modules = module;
   else
     {
	for ( m = modules; m->next; m = m->next );
	
	m->next = module;
     }
   
   module->next = NULL;
   
   return module;
}


void update_descriptors( )
{
   MODULE *module;
   
   for ( module = modules; module; module = module->next )
     {
	if ( !module->main_loop )
	  continue;
	
	if ( module->update_descriptors )
	  {
	     (*module->update_descriptors)( );
	     break;
	  }
     }
   
#if defined( FOR_WINDOWS )
     {
	void win_update_descriptors( ); /* From winmain.c */
	
	win_update_descriptors( );
     }
#endif
}



void update_modules( )
{
   MODULE *module;
   
   for ( module = modules; module; module = module->next )
     {
	if ( !module->main_loop )
	  continue;
	
	if ( module->update_modules )
	  {
	     (*module->update_modules)( );
	     break;
	  }
     }
   
#if defined( FOR_WINDOWS )
     {
	void win_update_modules( );
	
	win_update_modules( );
     }
#endif
}



void write_mod( char *file_name, char *type, FILE *fl )
{
   char buf[256];
   struct stat buf2;
   
   sprintf( buf, "./%s.%s", file_name, type );
   
   if ( stat( buf, &buf2 ) )
     fprintf( fl, "#" );
   
   fprintf( fl, "%s \"%s\"\n", type, buf );
}



void generate_config( char *file_name )
{
   FILE *fl;
   struct stat buf;
   char *type;
   
   if ( !stat( file_name, &buf ) )
     return;
   
   debugf( "No configuration file found, generating one." );
   
   fl = fopen( file_name, "w" );
   
   if ( !fl )
     {
	debugerr( file_name );
	return;
     }
   
   fprintf( fl, "# MudBot configuration file.\n"
	    "# Uncomment (i.e. remove the '#' before) anything you want to be parsed.\n"
	    "# If there's something you don't understand here, just leave it as it is.\n\n" );
   
   fprintf( fl, "# Ports to listen on. They can be as many as you want. \"default\" is 123.\n\n"
	    "# These will accept connections only from localhost.\n"
	    "allow_foreign_connections \"no\"\n\n"
	    "listen_on \"default\"\n"
	    "#listen_on \"23\"\n\n"
	    "# And anyone can connect to these.\n"
	    "allow_foreign_connections \"yes\"\n\n"
	    "#listen_on \"1523\"\n\n\n" );
   
   fprintf( fl, "# If these are commented or left empty, MudBot will ask the user where to connect.\n\n"
	    "host \"imperian.com\"\n"
	    "port \"23\"\n\n\n" );
   
   fprintf( fl, "# Proxy. The type can be \"http\" or \"socks5\". If empty, \"http\" is assumed.\n\n"
	    "proxy_type \"\"\n"
	    "proxy_host \"\"\n"
	    "proxy_port \"\"\n\n\n" );
   
   fprintf( fl, "# Autologin. Requires ATCP.\n"
	    "# Keep your password here at your own risk! Better just leave these empty.\n\n"
	    "user \"\"\n"
	    "pass \"\"\n\n\n" );
   
   fprintf( fl, "# Name to use on ATCP authentication. To disable ATCP use \"none\".\n"
	    "# To login as \"MudBot <actual version>\" use \"default\" or leave it empty.\n\n"
	    "atcp_login_as \"default\"\n"
	    "#atcp_login_as \"Nexus 3.0.1\"\n"
	    "#atcp_login_as \"JavaClient 2.4.8\"\n\n\n" );
   
   fprintf( fl, "# Mud Client Compression Protocol.\n\n"
	    "disable_mccp \"no\"\n\n\n" );
   
   fprintf( fl, "# Mud eXtension Protocol. Can be \"disabled\", \"locked\", \"open\", or \"secure\".\n"
	    "# Read the MXP specifications on www.zuggsoft.com for more info.\n\n"
	    "default_mxp_mode \"open\"\n\n\n" );
   
   fprintf( fl, "# Telnet Go-Ahead sequence. Some clients can't live with it, some can't without it.\n\n"
	    "strip_telnet_ga \"no\"\n\n\n" );
   
   fprintf( fl, "# Read and parse these files too.\n\n"
	    "include \"user.txt\"\n\n\n\n" );
   
#if defined( FOR_WINDOWS )
   fprintf( fl, "# Windows modules: Dynamic loaded libraries.\n\n" );
   type = "dll";
#else
   fprintf( fl, "# Linux modules: Shared object files.\n\n" );
   type = "so";
#endif
   
   write_mod( "imperian", type, fl );
   write_mod( "i_mapper", type, fl );
   write_mod( "i_offense", type, fl );
   write_mod( "voter", type, fl );
   write_mod( "i_script", type, fl );
   write_mod( "i_lua", type, fl );
   
   fprintf( fl, "\n" );
   
   fclose( fl );
}



void read_config( char *file_name, int silent )
{
   FILE *fl;
   MODULE *module;
   static int nested_files;
   void (*register_module)( MODULE *self );
   char line[256];
   char buf[256];
   char cmd[256];
   char *p;
   
   DEBUG( "read_config" );
   
   fl = fopen( file_name, "r" );
   
   if ( !fl )
     {
	if ( !silent )
	  debugerr( file_name );
	return;
     }
   
   while( 1 )
     {
	fgets( line, 256, fl );
	
	if ( feof( fl ) )
	  break;
	
	/* Skip if empty/comment line. */
	if ( line[0] == '#' || line[0] == ' ' || line[0] == '\n' || line[0] == '\r' || !line[0] )
	  continue;
	
	p = get_string( line, cmd, 256 );
	
	/* This file also contains some options. Load them too. */
	if ( !strcmp( cmd, "allow_foreign_connections" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     if ( !strcmp( buf, "yes" ) )
	       bind_to_localhost = 0;
	     else
	       bind_to_localhost = 1;
	  }
	else if ( !strcmp( cmd, "listen_on" ) && !copyover )
	  {
	     int init_socket( int port );
	     int port;
	     
	     get_string( p, buf, 256 );
	     
	     if ( !strcmp( buf, "default" ) )
	       port = default_listen_port;
	     else
	       port = atoi( buf );
	     
	     debugf( "Listening on port %d%s.", port, bind_to_localhost ? ", bound on localhost" : "" );
	     
	     init_socket( port );
	  }
	else if ( !strcmp( cmd, "host" ) || !strcmp( cmd, "hostname" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     strcpy( default_host, buf );
	  }
	else if ( !strcmp( cmd, "port" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     default_port = atoi( buf );
	  }
	else if ( !strcmp( cmd, "proxy_type" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     strcpy( proxy_type, buf );
	  }
	else if ( !strcmp( cmd, "proxy_host" ) || !strcmp( cmd, "proxy_hostname" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     if ( buf[0] )
	       proxy_host = strdup( buf );
	     else
	       proxy_host = NULL;
	  }
	else if ( !strcmp( cmd, "proxy_port" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     proxy_port = atoi( buf );
	  }
	else if ( !strcmp( cmd, "user" ) || !strcmp( cmd, "username" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     strcpy( default_user, buf );
	  }
	else if ( !strcmp( cmd, "pass" ) || !strcmp( cmd, "password" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     strcpy( default_pass, buf );
	  }
	else if ( !strcmp( cmd, "atcp_login_as" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     strcpy( atcp_login_as, buf );
	  }
	else if ( !strcmp( cmd, "disable_mccp" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     if ( !strcmp( buf, "yes" ) )
	       disable_mccp = 1;
	     else
	       disable_mccp = 0;
	  }
	else if ( !strcmp( cmd, "default_mxp_mode" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     if ( !strcmp( buf, "locked" ) || !buf[0] )
	       default_mxp_mode = 7;
	     else if ( !strcmp( buf, "secure" ) )
	       default_mxp_mode = 6;
	     else if ( !strcmp( buf, "open" ) )
	       default_mxp_mode = 5;
	     else
	       default_mxp_mode = 0;
	  }
	else if ( !strcmp( cmd, "strip_telnet_ga" ) )
	  {
	     get_string( p, buf, 256 );
	     
	     if ( !strcmp( buf, "yes" ) )
	       strip_telnet_ga = 1;
	     else
	       strip_telnet_ga = 0;
	  }
	else if ( !strcmp( cmd, "load" ) || !strcmp( cmd, "include" ) )
	  {
	     if ( nested_files++ > 100 )
	       return;
	     
	     get_string( p, buf, 256 );
	     
	     read_config( buf, 1 );
	  }
	
	/* Shared Object file. (.so) */
	else if ( !strcmp( cmd, "so" ) )
	  {
#if !defined( FOR_WINDOWS )
	     const char *dl_error;
	     void *dl_handle;
	     
	     get_string( p, buf, 256 );
	     
	     debugf( "Loading file '%s'.", buf );
	     
	     if ( !buf[0] )
	       {
		  debugf( "Syntax error in file '%s'.", file_name );
		  continue;
	       }
	     
	     dl_handle = dlopen( buf, RTLD_NOW );
	     
	     if ( !dl_handle )
	       {
		  debugf( "Can't load %s: %s", buf, dlerror( ) );
		  continue;
	       }
	     
	     /* Try both ways, for compatibility. */
	     register_module = dlsym( dl_handle, "module_register" );
	     dl_error = dlerror( );
	     
	     if ( dl_error != NULL )
	       {
		  register_module = dlsym( dl_handle, "_module_register" );
		  dl_error = dlerror( );
	       }
	     
	     if ( dl_error != NULL )
	       {
		  debugf( "Can't get the Register symbol from %s: %s",
			  buf, dl_error );
		  dlclose( dl_handle );
		  continue;
	       }
	     
	     module = add_module( );
	     module->register_module = register_module;
	     module->name = strdup( "unregistered" );
	     module->dl_handle = dl_handle;
	     module->file_name = strdup( buf );
#endif
	  }
	/* Dynamic Loaded Library file. (.dll) */
	else if ( !strcmp( cmd, "dll" ) )
	  {
#if defined( FOR_WINDOWS )
	     HINSTANCE mod;
	     
	     get_string( p, buf, 256 );
	     
	     debugf( "Loading file '%s'.", buf );
	     
	     if ( !buf[0] )
	       {
		  debugf( "Syntax error in file '%s'.", file_name );
		  continue;
	       }
	     
	     /* Prevent showing a Message box if the file is not found. */
	     SetErrorMode( SEM_NOOPENFILEERRORBOX );
	     
	     mod = LoadLibrary( buf );
	     
	     if ( mod <= (HINSTANCE) HINSTANCE_ERROR )
	       {
		  debugf( "Can't load %s.", buf );
		  continue;
	       }
	     
	     register_module = (void *) GetProcAddress( mod, "module_register" );
	     
	     if ( !register_module )
	       {
		  debugf( "Can't get the Register symbol from %s.", buf );
		  FreeLibrary( mod );
	       }
	     
	     module = add_module( );
	     module->register_module = register_module;
	     module->name = strdup( "unregistered" );
	     module->dll_hinstance = mod;
	     module->file_name = strdup( buf );
#endif
	  }
	else
	  {
	     debugf( "Syntax error in file '%s': unknown option '%s'.",
		     file_name, cmd );
	     continue;
	  }
     }
   
   fclose( fl );
   
   update_modules( );
}


void load_builtin_modules( )
{
   MODULE *module;
   int i;
   
   for ( i = 0; built_in_modules[i].name; i++ )
     {
	module = add_module( );
	module->register_module = built_in_modules[i].register_module;
	module->name = strdup( built_in_modules[i].name );
     }
}



void unload_module( MODULE *module )
{
   MODULE *m;
   DESCRIPTOR *d;
   TIMER *t;
   
   /* Make it clean itself up. */
   if ( module->unload )
     (module->unload)( );
   
   /* Unlink it. */
   if ( module == modules )
     modules = modules->next;
   else
     {
	for ( m = modules; m->next; m = m->next )
	  if ( m->next == module )
	    {
	       m->next = module->next;
	       break;
	    }
     }
   
   /* Remove all descriptors and timers that belong to it. */
   while ( 1 )
     {
	for ( d = descs; d; d = d->next )
	  if ( d->mod == module )
	    {
	       if ( d->fd > 0 )
		 c_close( d->fd );
	       remove_descriptor( d );
	       continue;
	    }
	break;
     }
   
   /* Make sure no timer linked to it exists anymore. */
   while ( 1 )
     {
        for ( t = timers; t; t = t->next )
          if ( t->mod == module )
            {
               unlink_timer( t );
               free_timer( t );
               break;
            }
        if ( !t )
          break;
     }
   
   /* Destroy all shared memory references from the table. */
   remove_shared_memory_by_module( module );
   
   /* Unlink it for good. */
#if !defined( FOR_WINDOWS )
   if ( module->dl_handle )
     dlclose( module->dl_handle );
#else
   if ( module->dll_hinstance )
     FreeLibrary( module->dll_hinstance );
#endif
   
   /* And free it up. */
   if ( module->name )
     free( module->name );
   if ( module->file_name )
     free( module->file_name );
   free( module );
}


void do_unload_module( char *name )
{
   MODULE *module;
   
   for ( module = modules; module; module = module->next )
     if ( !strcmp( name, module->name ) )
       break;
   
   if ( !module )
     {
	clientfb( "A module with that name was not found." );
	return;
     }
   
   unload_module( module );
   
   clientfb( "Module unloaded." );
   
   update_modules( );
}


void load_module( char *name )
{
#if !defined( FOR_WINDOWS )
   void (*register_module)( MODULE *self );
   const char *dl_error;
   void *dl_handle;
   char buf[2048];
   MODULE *module;
   
   sprintf( buf, "Loading file '%s'.", name );
   clientfb( buf );
   
   if ( !name[0] )
     {
	clientfb( "Null file name!" );
	return;
     }
   
   dl_handle = dlopen( name, RTLD_NOW );
   
   if ( !dl_handle )
     {
	sprintf( buf, "Can't load %s: %s", name, dlerror( ) );
	clientfb( buf );
	return;
     }
   
   /* Try both ways, for compatibility. */
   register_module = dlsym( dl_handle, "module_register" );
   dl_error = dlerror( );
   
   if ( dl_error != NULL )
     {
	register_module = dlsym( dl_handle, "_module_register" );
	dl_error = dlerror( );
     }
   
   if ( dl_error != NULL )
     {
	sprintf( buf, "Can't get the Register symbol from %s: %s",
		name, dl_error );
	clientfb( buf );
	dlclose( dl_handle );
	return;
     }
   
   module = add_module( );
   module->register_module = register_module;
   module->dl_handle = dl_handle;
   module->file_name = strdup( name );
   
#else
   
   void (*register_module)( MODULE *self );
   char buf[2048];
   MODULE *module;
   HINSTANCE mod;
   
   sprintf( buf, "Loading file '%s'.", name );
   clientfb( buf );
   
   if ( !name[0] )
     {
	clientfb( "Null file name!" );
	return;
     }
   
   /* Prevent showing a Message box if the file is not found. */
   SetErrorMode( SEM_NOOPENFILEERRORBOX );
   
   mod = LoadLibrary( name );
   
   if ( mod <= (HINSTANCE) HINSTANCE_ERROR )
     {
	sprintf( buf, "Can't load %s.", name );
	clientfb( buf );
	return;
     }
   
   register_module = (void *) GetProcAddress( mod, "module_register" );
   if ( !register_module )
     {
	sprintf( buf, "Can't get the Register symbol from %s.", name );
	clientfb( buf );
	FreeLibrary( mod );
	return;
     }
   
   module = add_module( );
   module->register_module = register_module;
   module->dll_hinstance = mod;
   module->file_name = strdup( name );
   
#endif
   
   current_mod = module;
   
   clientfb( "Gathering data.." );
   
   module->get_func = get_function;
   (module->register_module)( module );
   
   clientfb( "Initializing.." );
   if ( module->init_data )
     (module->init_data)( );
   else
     clientfb( "Eh, or not." );
   
   /* Make sure it knows and initializes MXP. */
   if ( module->mxp_enabled && client && mxp_enabled )
     (module->mxp_enabled)( );
   
   sprintf( buf, "Module %s has been loaded.", module->name );
   clientfb( buf );
   
   update_modules( );
}



void do_reload_module( char *name )
{
   MODULE *module;
   char file[512];
   
   for ( module = modules; module; module = module->next )
     if ( !strcmp( name, module->name ) )
       break;
   
   if ( !module )
     {
	clientfb( "A module with that name was not found." );
	return;
     }
   
   if ( !module->file_name || !module->file_name[0] )
     {
	clientfb( "The module's file name is not known." );
	return;
     }
   
   strcpy( file, module->file_name );
   
   clientfb( "Unloading module.." );
   unload_module( module );
   load_module( file );
   
   update_modules( );
}



void modules_register( )
{
   MODULE *mod;
   
   generate_config( "config.txt" );
   
   read_config( "config.txt", 0 );
   load_builtin_modules( );
   
   DEBUG( "modules_register" );
   
   mod_section = "Registering Modules";
   
   for ( mod = modules; mod; mod = mod->next )
     {
	/* The name was probably "unregistered". */
	if ( mod->name )
	  free( mod->name );
	
	current_mod = mod;
	mod->get_func = get_function;
	(mod->register_module)( mod );
	update_shared_memory( mod );
     }
   
   mod_section = NULL;
   
   update_modules( );
}


void module_show_version( )
{
   MODULE *module;
   char *OS;
   
   DEBUG( "module_show_version" );
   
#if defined( FOR_WINDOWS )
   OS = "(win)";
#else
   OS = "";
#endif
   
   /* Copyright notices. */
   
   clientff( C_B "MudBot v" C_G "%d" C_B "." C_G "%d" C_B "%s - Copyright (C) 2004, 2005  Andrei Vasiliu.\r\n\r\n"
	     "MudBot comes with ABSOLUTELY NO WARRANTY. This is free\r\n"
	     "software, and you are welcome to redistribute it under\r\n"
	     "certain conditions; See the GNU General Public License\r\n"
	     "for more details.\r\n\r\n",
	     main_version_major, main_version_minor, OS );
   
   mod_section = "Module Notice";
   /* Mod versions and notices. */
   for ( module = modules; module; module = module->next )
     {
	current_mod = module;
	clientff( C_B "Module: %s v" C_G "%d" C_B "." C_G "%d" C_B ".\r\n",
		  module->name, module->version_major, module->version_minor );
	
	if ( module->show_notice )
	  (*module->show_notice)( module );
     }
   mod_section = NULL;
}


void module_show_id( )
{
   MODULE *module;
   
   clientfb( "Source Identification" );
   clientf( "\r\n" C_D "(" C_B "MudBot:" C_D ")\r\n" C_W );
   clientf( main_id );
#if defined( FOR_WINDOWS )
   clientf( winmain_id );
#endif
   
   mod_section = "Showing ID.";
   for ( module = modules; module; module = module->next )
     {
	current_mod = module;
	clientff( C_D "\r\n(" C_B "%s:" C_D ")\r\n" C_W, module->name );
	if ( module->id )
	  clientf( module->id );
	else
	  clientf( "-- Unknown --\r\n" );
     }
   mod_section = NULL;
}



void module_init_data( )
{
   MODULE *mod;
   
   DEBUG( "module_init_data" );
   
   mod_section = "Initializing Module";
   for ( mod = modules; mod; mod = mod->next )
     {
	current_mod = mod;
	if ( mod->init_data )
	  (mod->init_data)( );
	update_shared_memory( mod );
     }
   mod_section = NULL;
}


/* A fuction which ignores unprintable characters. */
void strip_unprint( char *string, char *dest )
{
   char *a, *b;
   
   DEBUG( "strip_unprint" );
   
   for ( a = string, b = dest; *a; a++ )
     if ( isprint( *a ) )
       {
	  *b = *a;
	  b++;
       }
   *b = 0;
}



/* A function which ignores color codes. */
void strip_colors( char *string, char *dest )
{
   char *a, *b;
   int ignore = 0;
   
   DEBUG( "strip_colors" );
   
   for ( a = string, b = dest; *a; a++ )
     {
	if ( *a == '\33' )
	  ignore = 1;
	else if ( ignore && *a == 'm' )
	  ignore = 0;
	else if ( !ignore )
	  *b = *a, b++;
     }
   *b = 0;
}



void module_mxp_enabled( )
{
   MODULE *module;
   
   DEBUG( "module_mxp_enabled" );
   
   mod_section = "Notifying modules about MXP.";
   for ( module = modules; module; module = module->next )
     {
	current_mod = module;
	if ( module->mxp_enabled )
	  (module->mxp_enabled)( );
	update_shared_memory( module );
     }
   mod_section = NULL;
}


void restart_mccp( TIMER *self )
{
   char mccp_start[] = { IAC, DO, TELOPT_COMPRESS2, 0 };
   
   send_to_server( mccp_start );
}



void module_process_server_line( LINE *line )
{
   char mccp_stop[] = { IAC, DONT, TELOPT_COMPRESS2, 0 };
   MODULE *module;
   
   DEBUG( "module_process_server_line" );
   
   current_new_line = line;
   clientf_modifies_suffix = 1;
   
   /* Our own triggers, to start/stop MCCP when needed. */
   if ( compressed &&
	( !cmp( "you are out of the land.", line->line ) ) )
     {
	add_timer( "restart_mccp", 20, restart_mccp, 0, 0, 0 );
	send_to_server( mccp_stop );
     }
   if ( !compressed && !disable_mccp &&
	( !cmp( "You cease your praying.", line->line ) ) )
     {
	del_timer( "restart_mccp" );
	restart_mccp( NULL );
     }
#if defined( FOR_WINDOWS )
   if ( compressed &&
	( !cmp( "You enter the editor.", line->line ) ||
	  !cmp( "You begin writing.", line->line ) ) )
     {
	char mccp_start[] = { IAC, DO, TELOPT_COMPRESS2, 0 };
	
	/* Only briefly, ATCP over MCCP is very buggy. */
	verbose_mccp = 0;
	debugf( "Temporarely stopping MCCP." );
	send_to_server( mccp_stop );
	send_to_server( mccp_start );
     }
#endif
   
   mod_section = "Processing server line";
   for ( module = modules; module; module = module->next )
     {
	current_mod = module;
	if ( module->process_server_line )
	  (module->process_server_line)( line );
	update_shared_memory( module );
     }
   mod_section = NULL;
   
   clientf_modifies_suffix = 0;
}


void module_process_server_prompt( LINE *line )
{
   MODULE *module;
   
   DEBUG( "module_process_server_prompt" );
   
   current_new_line = line;
   clientf_modifies_suffix = 1;
   
   /* It won't print that echo_off, so I'll force it. */
   if ( strstr( line->line, "password" ) )
     {
	char telnet_echo_off[ ] = { IAC, WILL, TELOPT_ECHO, '\0' };
	clientf( telnet_echo_off );
     }
   
   mod_section = "Processing server prompt";
   for ( module = modules; module; module = module->next )
     {
	current_mod = module;
	if ( module->process_server_prompt )
	  (module->process_server_prompt)( line );
	update_shared_memory( module );
     }
   mod_section = NULL;
   
   clientf_modifies_suffix = 0;
}


int module_process_client_command( char *rawcmd )
{
   MODULE *module;
   char cmd[4096];
   
   DEBUG( "module_process_client_command" );
   
   /* Strip weird characters */
   strip_unprint( rawcmd, cmd );
   
   mod_section = "Processing client command";
   for ( module = modules; module; module = module->next )
     {
	current_mod = module;
	if ( module->process_client_command )
	  if ( !(module->process_client_command)( cmd ) )
	    return 0;
	update_shared_memory( module );
     }
   mod_section = NULL;
   
   return 1;
}


int module_process_client_aliases( char *line )
{
   MODULE *module;
   char cmd[4096];
   int used = 0;
   
   DEBUG( "module_process_client_aliases" );
   
   /* Strip weird characters, if there are any left. */
   strip_unprint( line, cmd );
   
   /* Buffer all that is sent to the server, to send it all at once. */
   buffer_send_to_server = 1;
   send_buffer[0] = 0;
   
   mod_section = "Processing client aliases";
   for ( module = modules; module; module = module->next )
     {
	current_mod = module;
	if ( module->process_client_aliases )
	  used = (module->process_client_aliases)( cmd ) || used;
	update_shared_memory( module );
     }
   mod_section = NULL;
   
   buffer_send_to_server = 0;
   if ( send_buffer[0] )
     send_to_server( send_buffer );
   
   return used;
}


void show_modules( )
{
   MODULE *module;
   char buf[256];
   
   DEBUG( "show_modules" );
   
   clientfb( "Modules:" );
   for ( module = modules; module; module = module->next )
     {
	sprintf( buf, C_B " - %-10s v" C_G "%d" C_B "." C_G "%d" C_B ".\r\n" C_0,
		 module->name, module->version_major, module->version_minor );
	
	clientf( buf );
     }
}


void logff( char *type, char *string, ... )
{
   FILE *fl;
   char buf [ 4096 ];
   va_list args;
   struct timeval tv;
   
   if ( !logging )
     return;
   
   va_start( args, string );
   vsnprintf( buf, 4096, string, args );
   va_end( args );
   
   fl = fopen( log_file, "a" );
   
   if ( !fl )
     return;
   
   gettimeofday( &tv, NULL );
   
   if ( type )
     fprintf( fl, "(%3ld.%2ld) [%s]: %s\n", (long) (tv.tv_sec % 1000),
	      (long) (tv.tv_usec / 10000), type, string );
   else
     fprintf( fl, "(%3ld.%2ld) %s\n", (long) (tv.tv_sec % 1000),
	      (long) (tv.tv_usec / 10000), string );
   
   fclose( fl );
}



void log_bytes( char *type, char *string, int bytes )
{
   char buf[12288]; /* 4096*3 */
   char buf2[16];
   char *b = buf, *s;
   int i = 0;
   
   if ( !logging )
     return;
   
   *(b++) = '[';
   s = type;
   while ( *s )
     *(b++) = *(s++);
   *(b++) = ']';
   *(b++) = ' ';
   *(b++) = '\'';
   
   s = string;
   
   while ( i < bytes )
     {
	if ( ( string[i] >= 'a' && string[i] <= 'z' ) ||
	     ( string[i] >= 'A' && string[i] <= 'Z' ) ||
	     ( string[i] >= '0' && string[i] <= '9' ) ||
	     string[i] == ' ' || string[i] == '.' ||
	     string[i] == ',' || string[i] == ':' ||
	     string[i] == '(' || string[i] == ')' )
	  {
	     *(b++) = string[i++];
	  }
	else
	  {
	     *(b++) = '[';
	     sprintf( buf2, "%d", (int) string[i++] );
	     s = buf2;
	     while ( *s )
	       *(b++) = *(s++);
	     *(b++) = ']';
	  }
     }
   
   *(b++) = '\'';
   *(b++) = 0;
   
   logff( NULL, buf );
}


int get_timer( )
{
   static struct timeval tvold, tvnew;
   int usec, sec;
   
   gettimeofday( &tvnew, NULL );
   
   usec = tvnew.tv_usec - tvold.tv_usec;
   sec = tvnew.tv_sec - tvold.tv_sec;
   tvold = tvnew;
   
   return usec + ( sec * 1000000 );
}


void add_descriptor( DESCRIPTOR *desc )
{
   DESCRIPTOR *d;
   
   /* Make a few checks on the descriptor that is to be added. */
   /* ... */
   
   /* Link it at the end of the main chain. */
   
   desc->next = NULL;
   
   if ( !descs )
     {
	descs = desc;
     }
   else
     {
	for ( d = descs; d->next; d = d->next );
	
	d->next = desc;
     }
   
   update_descriptors( );
}


void remove_descriptor( DESCRIPTOR *desc )
{
   DESCRIPTOR *d;
   
   if ( !desc )
     {
	debugf( "remove_descriptor: Called with null argument." );
	return;
     }
   
   /* Unlink it from the chain. */
   
   if ( descs == desc )
     {
	descs = descs->next;
     }
   else
     {
	for ( d = descs; d; d = d->next )
	  if ( d->next == desc )
	    {
	       d->next = desc->next;
	       break;
	    }
     }
   
   /* This is so we know if it was removed, while processing it. */
   if ( current_descriptor == desc )
     current_descriptor = NULL;
   
   /* Free it up. */
   
   if ( desc->name )
     free( desc->name );
   if ( desc->description )
     free( desc->description );
   free( desc );
   
   update_descriptors( );
}




void assign_server( int fd )
{
   if ( server )
     {
	if ( server->fd && server->fd != fd )
	  c_close( server->fd );
	
	if ( !fd )
	  {
	     remove_descriptor( server );
	     server = NULL;
	  }
	else
	  {
	     server->fd = fd;
	  }
	
	update_descriptors( );
     }
   else if ( fd )
     {
	void fd_server_in( DESCRIPTOR *self );
	void fd_server_exc( DESCRIPTOR *self );
	
	/* Server. */
	server = calloc( 1, sizeof( DESCRIPTOR ) );
	server->name = strdup( "Server" );
	server->description = strdup( "Connection to the mud server" );
	server->mod = NULL;
	server->fd = fd;
	server->callback_in = fd_server_in;
	server->callback_out = NULL;
	server->callback_exc = fd_server_exc;
	add_descriptor( server );
     }
}


void assign_client( int fd )
{
   if ( client )
     {
	if ( client->fd && client->fd != fd )
	  c_close( client->fd );
	
	if ( !fd )
	  {
	     remove_descriptor( client );
	     client = NULL;
	  }
	else
	  {
	     client->fd = fd;
	  }
	
	update_descriptors( );
     }
   else if ( fd )
     {
	void fd_client_in( DESCRIPTOR *self );
	void fd_client_out( DESCRIPTOR *self );
	void fd_client_exc( DESCRIPTOR *self );
	
	/* Client. */
	client = calloc( 1, sizeof( DESCRIPTOR ) );
	client->name = strdup( "Client" );
	client->description = strdup( "Connection to the mud client" );
	client->mod = NULL;
	client->fd = fd;
	client->callback_in = fd_client_in;
	client->callback_out = fd_client_out;
	client->callback_exc = fd_client_exc;
	add_descriptor( client );
     }
}



char *get_socket_error( int *nr )
{
#if !defined( FOR_WINDOWS )
   if ( nr )
     *nr = errno;
   
   return strerror( errno );
#else
   char *win_str_error( int error );
   int error;
   
   error = WSAGetLastError( );
   
   if ( nr )
     *nr = error;
   
   return win_str_error( error );
#endif
}

char *get_connect_error( )
{
   return connection_error;
}


/* Return values:
 *  0 and above: Socket/file descriptor. (Success)
 *  -1: Invalid arguments.
 *  -2: Host not found.
 *  -3: Can't create socket.
 *  -4: Unable to connect.
 */

int mb_connect( char *hostname, int port )
{
   struct hostent *host;
   struct in_addr hostip;
   struct sockaddr_in saddr;
   int i, sock;
   
   if ( !hostname && !port )
     {
	hostname = proxy_host;
	port = proxy_port;
     }
   
   if ( hostname[0] == '\0' || port < 1 || port > 65535 )
     {
	connection_error = "Host name or port number invalid";
	return -1;
     }
   
   host = gethostbyname( hostname );
   
   if ( !host )
     {
	connection_error = "Host not found";
	return -2;
     }
   
   /* Build host IP. */
   hostip = *(struct in_addr*) host->h_addr;
   
   /* Build the sinaddr(_in) structure. */
   saddr.sin_family = AF_INET;
   saddr.sin_port = htons( port );
   saddr.sin_addr = hostip;
   
   /* Get a socket... */
   sock = socket( saddr.sin_family, SOCK_STREAM, 0 );
   
   if ( sock < 0 )
     {
	connection_error = "Unable to create a network socket";
	return -3;
     }
   
   i = connect( sock, (struct sockaddr*) &saddr, sizeof( saddr ) );
   
   if ( i )
     {
	connection_error = get_socket_error( NULL );
	
	c_close( sock );
	return -4;
     }
   
   connection_error = "Success";
   return sock;
}



char *socks5_msgs( int type, unsigned char msg )
{
   if ( type == 1 )
     {
	if ( msg == 0x00 )
	  return "No authentification required";
	if ( msg == 0xFF )
	  return "No acceptable methods";
	return "Unknown Socks5 message";
     }
   
   if ( type == 2 )
     {
	if ( msg == 0x00 )
	  return "Succeeded";
	if ( msg == 0x01 )
	  return "General SOCKS server failure";
	if ( msg == 0x02 )
	  return "Connection not allowed by ruleset";
	if ( msg == 0x03 )
	  return "Network unreachable";
	if ( msg == 0x04 )
	  return "Host unreachable";
	if ( msg == 0x05 )
	  return "Connection refused";
	if ( msg == 0x06 )
	  return "TTL expired";
	if ( msg == 0x07 )
	  return "Command not supported";
	if ( msg == 0x08 )
	  return "Address type not supported";
	return "Unknown Socks5 message";
     }
   
   return "Unknown type";
}



int mb_connect_request( int sock, char *hostname, int port )
{
   char string[1024];
   int len;
   
   if ( sock < 0 )
     return sock;
   
   if ( !strcmp( proxy_type, "socks5" ) )
     {
	string[0] = 0x05;
	string[1] = 0x01;
	string[2] = 0x00;
	len = 3;
	
	/* Sending: Version5, no authentication methods. */
	c_write( sock, string, len );
	len = c_read( sock, string, 1024 );
	
	if ( len <= 0 )
	  {
	     connection_error = "Read error from proxy";
	     c_close( sock );
	     return -1;
	  }
	
	/* Happens if the proxy wants some sort of authentication. */
	if ( string[1] != 0x00 )
	  {
	     connection_error = socks5_msgs( 1, string[1] );
	     c_close( sock );
	     return -1;
	  }
	
	string[0] = 0x05; /* Version 5 */
	string[1] = 0x01; /* Command: Connect */
	string[2] = 0x00; /* Reserved */
	string[3] = 0x03; /* Type: Host Name */
	len = strlen( hostname ); /* Hostname */
	string[4] = len;
	memcpy( string+5, hostname, len );
	string[5+len] = port >> 8; /* Port */
	string[6+len] = port & 0xFF;
	
	len = 7+len;
	
	/* Sending: Version5, Connect, Hostname. */
	c_write( sock, string, len );
	len = c_read( sock, string, 1024 );
	
	if ( len <= 0 )
	  {
	     connection_error = "Read error from proxy";
	     c_close( sock );
	     return -1;
	  }
	
	if ( len != 10 )
	  {
	     connection_error = "Buggy or unknown response from proxy";
	     c_close( sock );
	     return -1;
	  }
	
	/* "Version%d, %s, %s, %d-%d-%d-%d, %d-%d." */
	
	if ( string[1] != 0x00 )
	  {
	     connection_error = socks5_msgs( 2, string[1] );
	     c_close( sock );
	     return -1;
	  }
	
	return sock;
     }
   else
     {
	/* HTTP proxy. */
	int nr;
	
	sprintf( string, "CONNECT %s:%d HTTP/1.0\n\n", hostname, port );
	len = strlen( string );
	
	c_write( sock, string, len );
	len = c_read( sock, string, 12 );
	
	/* strlen( "HTTP/1.0 200" ) == 12 */
	
	if ( len < 12 )
	  {
	     connection_error = "Read error from proxy";
	     c_close( sock );
	     return -1;
	  }
	
	if ( strncmp( string + 9, "200", 3 ) )
	  {
	     /* Get the error message. */
	     char *p;
	     
	     strncpy( string, string+9, 3 );
	     len = c_read( sock, string+3, 1024-3 );
	     
	     if ( len <= 0 )
	       {
		  connection_error = "Read error from proxy";
		  c_close( sock );
		  return -1;
	       }
	     
	     p = string;
	     while ( *p && *p != '\n' && *p != '\r' )
	       p++;
	     *p = 0;
	     
	     /* Memory leak. But I don't care. */
	     connection_error = strdup( string );
	     return -1;
	  }
	
	/* Seek for a double new line. */
	nr = 0;
	while ( 1 )
	  {
	     if ( c_read( sock, string, 1 ) <= 0 )
	       {
		  connection_error = "Read error from proxy";
		  c_close( sock );
		  return -1;
	       }
	     
	     if ( string[0] == '\n' )
	       nr++;
	     else if ( string[0] == '\r' )
	       continue;
	     else
	       nr = 0;
	     
	     if ( nr == 2 )
	       break;
	  }
	
	return sock;
     }
}



void check_for_server( void )
{
   void client_telnet( char *src, char *dst, int *bytes );
   static char request[4096];
   char raw_buf[4096], buf[4096];
   char hostname[4096];
   char *c, *pos;
   int port;
   int bytes;
   int found = 0;
   int server;
   
   bytes = c_read( client->fd, raw_buf, 4096 );
   
   if ( bytes == 0 )
     {
	debugf( "Eof on read." );
     }
   else if ( bytes < 0 )
     {
	debugf( "check_for_server: %s.", get_socket_error( NULL ) );
     }
   if ( bytes <= 0 )
     {
	assign_server( 0 );
	assign_client( 0 );
	return;
     }
   
   buf[bytes] = '\0';
   
   log_bytes( "c->m (conn)", buf, bytes );
   
   client_telnet( raw_buf, buf, &bytes );
   
   strncat( request, buf, bytes );
   
   /* Skip the weird characters */
   for ( c = request; !isprint( *c ) && *c; c++ );
   
   /* Search for a newline */
   for ( pos = c; *pos; pos++ )
     {
	if ( *pos == '\n' )
	  {
	     found = 1;
	     break;
	  }
     }
   
   if ( found && ( pos = strstr( c, "connect" ) ) )
     {
	int sock;
	
	sscanf( pos + 8, "%s %d", hostname, &port );
	
	if ( hostname[0] == '\0' || port < 1 || port > 65535 )
	  {
	     debugf( "Host name or port number invalid." );
	     clientfb( "Host name or port number invalid." );
	     request[0] = '\0';
	     return;
	  }
	
	debugf( "Connecting to: %s %d.", hostname, port );
	clientf( C_B "Connecting... " C_0 );
	
	sock = mb_connect( hostname, port );
	
	if ( sock < 0 )
	  {
	     debugf( "Failed (%s)", get_connect_error( ) );
	     clientff( C_B "%s.\r\n" C_0, get_connect_error( ) );
	     request[0] = '\0';
	     server = 0;
	     return;
	  }
	
	debugf( "Connected." );
	clientf( C_B "Done.\r\n" C_0 );
	clientfb( "Send `help to get some help." );
	request[0] = '\0';
	
	strcpy( server_hostname, hostname );
	
	assign_server( sock );
     }
   else if ( found )
     {
	clientfb( "Bad connection string, try again..." );
	request[0] = '\0';
     }
}



void fd_client_in( DESCRIPTOR *self )
{
   int process_client( void );
   
//   if ( !server )
//     check_for_server( );
//   else
//     {
	if ( process_client( ) )
	  assign_client( 0 );
//     }
}


void fd_client_out( DESCRIPTOR *self )
{
   /* Ask for MXP support. */
   
   char will_mxp[] = { IAC, WILL, TELOPT_MXP, 0 };
   
   mxp_enabled = 0;
   if ( default_mxp_mode )
     clientf( will_mxp );
   
   self->callback_out = NULL;
   update_descriptors( );
}


void fd_client_exc( DESCRIPTOR *self )
{
   assign_client( 0 );
   
   debugf( "Exception raised on client descriptor." );
}


void fd_server_in( DESCRIPTOR *self )
{
   int process_server( void );
   
   if ( process_server( ) )
     {
	assign_client( 0 );
	assign_server( 0 );
	return;
     }
}


void fd_server_exc( DESCRIPTOR *self )
{
   if ( client )
     {
	clientfb( "Exception raised on the server's connection. Closing." );
	assign_client( 0 );
     }
   
   debugf( "Connection error from the server." );
   /* Return, and listen again. */
   return;
}



void new_descriptor( int control )
{
   struct sockaddr_in  sock;
   struct hostent     *from;
   char buf[4096];
   unsigned int size;
   int addr, desc;
   int ip1, ip2, ip3, ip4;

   size = sizeof( sock );
   if ( ( desc = accept( control, (struct sockaddr *) &sock, &size) ) < 0 )
     {
	debugf( "New_descriptor: accept: %s.", get_socket_error( NULL ) );
	return;
     }
   
   addr = ntohl( sock.sin_addr.s_addr );
   ip1 = ( addr >> 24 ) & 0xFF;
   ip2 = ( addr >> 16 ) & 0xFF;
   ip3 = ( addr >>  8 ) & 0xFF;
   ip4 = ( addr       ) & 0xFF;
   
   sprintf( buf, "%d.%d.%d.%d", ip1, ip2, ip3, ip4 );
   
   from = gethostbyaddr( (char *) &sock.sin_addr,
			 sizeof(sock.sin_addr), AF_INET );
   
   debugf( "Sock.sinaddr:  %s (%s)", buf, from ? from->h_name : buf );
   
   if ( client )
     {
	char *msg = "Only one connection accepted.\r\n";
	debugf( "Refusing." );
	c_write( desc, msg, strlen( msg ) );
	c_close( desc );
	
	/* Let's inform the real one, just in case. */
	clientf( C_B "\r\n[" C_R "Connection attempt from: " C_B );
	clientf( buf );
	if ( from )
	  {
	     clientf( C_R " (" C_B );
	     clientf( from->h_name );
	     clientf( C_R ")" );
	  }
	clientf( C_B "]\r\n" C_0 );
	
	/* Return the same, don't change it. */
	return;
     }
   else if ( !server )
     {
	strcpy( client_hostname, from ? from->h_name : buf );
	
	assign_client( desc );
	
	module_show_version( );
	
	if ( default_port && default_host[0] )
	  {
	     int sock;
	     
	     if ( !proxy_host || !proxy_port )
	       {
		  debugf( "Connecting to: %s %d.", default_host, default_port );
		  clientff( C_B "Connecting to %s:%d... " C_0, default_host, default_port );
		  
		  sock = mb_connect( default_host, default_port );
	       }
	     else
	       {
		  debugf( "Connecting to: %s %d.", proxy_host, proxy_port );
		  clientff( C_B "Connecting to %s:%d... " C_0, proxy_host, proxy_port );
		  
		  sock = mb_connect( NULL, 0 );
	       }
	     
	     if ( proxy_host && proxy_port && sock >= 0 )
	       {
		  clientf( C_B "Done.\r\n" C_0 );
		  
		  debugf( "Asking for: %s %d.", default_host, default_port );
		  clientff( C_B "Requesting %s:%d... " C_0, default_host, default_port );
		  
		  sock = mb_connect_request( sock, default_host, default_port );
	       }
	     
	     if ( sock < 0 )
	       {
		  debugf( "Failed (%s)", get_connect_error( ) );
		  clientff( C_B "%s.\r\n" C_0, get_connect_error( ) );
		  server = 0;
		  
		  /* Don't return. Let it display the Syntax line. */
	       }
	     else
	       {
		  debugf( "Connected." );
		  clientf( C_B "Done.\r\n" C_0 );
		  clientfb( "Send `help to get some help." );
		  
		  strcpy( server_hostname, default_host );
		  
		  assign_server( sock );
		  
		  return;
	       }
	  }
	
	clientf( C_B "[" C_R "Syntax: connect hostname portnumber" C_B "]\r\n" C_0 );
     }
   else
     {
	char msg[256];
	sprintf( msg, C_B "[" C_R "Welcome back." C_B "]\r\n" C_0 );
	c_write( desc, msg, strlen( msg ) );
	
	if ( buffer_noclient[0] )
	  {
	     sprintf( msg, C_B "[" C_R "Buffered data:" C_B "]\r\n" C_0 );
	     c_write( desc, msg, strlen( msg ) );
	     c_write( desc, buffer_noclient, strlen( buffer_noclient ) );
	     buffer_noclient[0] = 0;
	     sprintf( msg, "\r\n" C_B "[" C_R "EOB" C_B "]\r\n" C_0 );
	     c_write( desc, msg, strlen( msg ) );
	  }
	else
	  {
	     sprintf( msg, C_B "[" C_R "Nothing happened meanwhile." C_B "]\r\n" C_0 );
	     c_write( desc, msg, strlen( msg ) );
	  }
	
	strcpy( client_hostname, from ? from->h_name : buf );
	
	assign_client( desc );
     }
}



void fd_control_in( DESCRIPTOR *self )
{
   new_descriptor( self->fd );
}


/* Send it slowly, and only if we can. */
void write_error_buffer( DESCRIPTOR *self )
{
   int bytes;
   
   if ( !client )
     {
	debugf( "No more client to write to!" );
	exit( 1 );
     }
   
   while( 1 )
     {
	bytes = c_write( client->fd, buffer_write_error,
			 bw_end_offset > 4096 ? 4096 : bw_end_offset );
	
	if ( bytes < 0 )
	  break;
	
	buffer_write_error += bytes;
	bw_end_offset -= bytes;
	
	if ( !bw_end_offset )
	  {
	     debugf( "Everything sent, freeing the memory buffer." );
	     unable_to_write = 0;
	     free( initial_big_buffer );
	     self->callback_out = NULL;
	     update_descriptors( );
	     break;
	  }
     }
}



void send_to_client( char *data, int bytes )
{
   MODULE *module;
   
   if ( bytes < 1 )
     return;
   
   /* Show it off to all the modules... Maybe they want to log it. */
   for ( module = modules; module; module = module->next )
     {
	if ( !module->send_to_client )
	  continue;
	
        if ( (*module->send_to_client)( data, bytes ) )
          return;
     }
   
   if ( unable_to_write )
     {
	if ( unable_to_write == 1 )
	  {
	     memcpy( buffer_write_error + bw_end_offset, data, bytes );
	     bw_end_offset += bytes;
	  }
	
	return;
     }
   
#if defined( FOR_WINDOWS )
   WSASetLastError( 0 );
#endif
   
   if ( ( c_write( client->fd, data, bytes ) < 0 ) )
     {
	char *error;
	int errnr;
	
	error = get_socket_error( &errnr );
	
#if defined( FOR_WINDOWS )
	if ( errnr == WSAEWOULDBLOCK )
	  {
	     debugf( "Unable to write to the client! Buffering until we can." );
	     
	     /* Get 16 Mb of memory. We'll need a lot. */
	     buffer_write_error = malloc( 1048576 * 16 );
	     
	     if ( !buffer_write_error )
	       unable_to_write = 2;
	     else
	       {
		  unable_to_write = 1;
		  initial_big_buffer = buffer_write_error;
		  memcpy( buffer_write_error, data, bytes );
		  bw_end_offset = bytes;
		  
		  client->callback_out = write_error_buffer;
		  update_descriptors( );
	       }
	     return;
	  }
#endif
	
	debugf( "send_to_client: (%d) %s.", errnr, error );
	assign_client( 0 );
     }
}



void add_buffer( char *string, char **buffer, char **pointer, char **max )
{
   if ( !*buffer )
     {
	*buffer = malloc( 4092 );
	*pointer = *buffer;
	*max = *buffer + 4092;
     }
   
   while ( *string )
     {
	*((*pointer)++) = *(string++);
	if ( *pointer == *max )
	  {
	     size_t size;
	     size = *max - *buffer + 4092;
	     *buffer = realloc( *buffer, size );
	     *max = *buffer + size;
	     *pointer = *buffer + size - 4092;
	  }
     }
   
   **pointer = 0;
}


void shrink_buffer( char **buffer, char **pointer, char **max )
{
   /* Shrink it back down, if it was reallocated. */
   if ( *max - *buffer != 4096 )
     {
	*buffer = realloc( *buffer, 4096 );
	*max = *buffer + 4096;
     }
   
   /* And make sure the pointer points in the right direction. */
   if ( *pointer != *buffer )
     *pointer = *buffer;
   
   **pointer = 0;
}



void prefix( char *string )
{
   if ( current_new_line )
     add_buffer( string, &prefix_buffer, &prefix_p, &prefix_max );
   else
     clientf( string );
}

void suffix( char *string )
{
   if ( current_new_line )
     add_buffer( string, &suffix_buffer, &suffix_p, &suffix_max );
   else
     clientf( string );
}

void replace( char *string )
{
   add_buffer( string, &replace_buffer, &replace_p, &replace_max );
}

void prefixf( char *string, ... )
{
   char buf [ 4096 ];
   
   va_list args;
   va_start( args, string );
   vsnprintf( buf, 4096, string, args );
   va_end( args );
   
   prefix( buf );
}

void suffixf( char *string, ... )
{
   char buf [ 4096 ];
   
   va_list args;
   va_start( args, string );
   vsnprintf( buf, 4096, string, args );
   va_end( args );
   
   suffix( buf );
}


void insert( int pos, char *string )
{
   if ( !current_new_line )
     {
	debugf( "Warning! insert() called with no current line known!" );
	return;
     }
   
   if ( pos > current_new_line->len )
     {
	debugf( "Warning! insert() was attempted over the length limit!" );
	debugf( "Line: [%s]", current_new_line->line );
     }
   
   if ( !current_new_line->inlines[pos] )
     {
	current_new_line->inlines[pos] = malloc( strlen( string ) );
	strcpy( current_new_line->inlines[pos], string );
     }
   else
     {
	current_new_line->inlines[pos] = realloc( current_new_line->inlines[pos], strlen( current_new_line->inlines[pos] ) + strlen( string ) );
	strcat( current_new_line->inlines[pos], string );
     }
}



void clientf( char *string )
{
   int length;
   
   if ( clientf_modifies_suffix )
     {
	suffix( string );
	
	return;
     }
   
   if ( buffer_output )
     {
	strcat( buffer_data, string );
	return;
     }
   
   if ( !client )
     {
	/* Client crashed, or something? Then we'll remember what the server said. */
	if ( server )
	  strcat( buffer_noclient, string );
	return;
     }
   
   length = strlen( string );
   
   send_to_client( string, length );
}


void clientff( char *string, ... )
{
   char buf [ 4096 ];
   
   va_list args;
   va_start( args, string );
   vsnprintf( buf, 4096, string, args );
   va_end( args );
   
   clientf( buf );
}


/* Just to avoid too much repetition. */
void clientfb( char *string )
{
   clientf( C_B "[" C_R );
   clientf( string );
   clientf( C_B "]\r\n" C_0 );
}


void clientfr( char *string )    
{
   clientf( C_R "[" );	   
   clientf( string );	     
   clientf( "]\r\n" C_0 );
}


void send_to_server( char *string )
{
   MODULE *module;
   int length;
   int bytes;
   
   if ( buffer_send_to_server )
     {
	strcat( send_buffer, string );
	return;
     }
   
   if ( !server )
     return;
   
   length = strlen( string );
   
   /* Show it off to all the modules... Maybe they want to log it. */
   for ( module = modules; module; module = module->next )
     {
	if ( !module->send_to_server )
	  continue;
	
        if ( (*module->send_to_server)( string, length ) )
          return;
     }
   
   bytes_sent += length;
   
   bytes = c_write( server->fd, string, length );
   
   if ( bytes < 0 )
     {
	debugf( "send_to_server: %s.", get_socket_error( NULL ) );
	exit( 1 );
     }
   
   sent_something = 1;
}


void copy_over( char *reason )
{
   DESCRIPTOR *d;
   char cpo0[64], cpo1[64], cpo2[64], cpo3[64];
   
   if ( !control || !client || !server )
     {
	debugf( "Control, client or server, does not exist! Can not do a copyover." );
	return;
     }
   
   /* Close all unneeded descriptors. */
   for ( d = descs; d; d = d->next )
     {
	if ( d->fd < 1 )
	  continue;
	
	if ( d == control || d == client || d == server )
	  continue;
	
	c_close( d->fd );
     }
   
   sprintf( cpo0, "--%s", reason );
   sprintf( cpo1, "%d", control->fd );
   sprintf( cpo2, "%d", client->fd );
   sprintf( cpo3, "%d", server->fd );
   
   /* Exec - descriptors are kept alive. */
   execl( exec_file, exec_file, cpo0, cpo1, cpo2, cpo3, NULL );
   
   /* Failed! A successful exec never returns... */
   debugerr( "Failed Copyover" );
}



void unlink_timer( TIMER *timer )
{
   TIMER *t;
   
   if ( timers == timer )
     timers = timer->next;
   else
     for ( t = timers; t; t = t->next )
       if ( t->next == timer )
         {
            t->next = timer->next;
            break;
         }
}



void free_timer( TIMER *timer )
{
   if ( timer->destroy_cb )
     timer->destroy_cb( timer );
   
   if ( timer->name )
     free( timer->name );
   free( timer );
}



void check_timers( )
{
   TIMER *t;
   struct timeval now;
   
   gettimeofday( &now, NULL );
   
   /* Check the timers. */
   while ( 1 )
     {
        /* A While loop is much safer than t_next = t->next. */
        
        for ( t = timers; t; t = t->next )
          if ( t->fire_at_sec < now.tv_sec ||
               ( t->fire_at_sec == now.tv_sec &&
                 t->fire_at_usec <= now.tv_usec ) )
            {
               /* Remove first, execute later. Why? Because it may be added again. */
               unlink_timer( t );
               
               if ( t->callback )
                 (*t->callback)( t );
               
               free_timer( t );
               
               break;
            }
        
        if ( !t )
          break;
     }
}



void get_first_timer( time_t *sec, time_t *usec )
{
   TIMER *t, *first = NULL;
   struct timeval now;
   
   for ( t = timers; t; t = t->next )
     if ( !first || t->fire_at_sec < first->fire_at_sec ||
          ( t->fire_at_sec == first->fire_at_sec &&
            t->fire_at_usec < first->fire_at_usec ) )
       first = t;
   
   if ( !first )
     return;
   
   gettimeofday( &now, NULL );
   
   *sec = first->fire_at_sec - now.tv_sec;
   *usec = first->fire_at_usec - now.tv_usec;
   if ( *usec < 0 )
     {
        *usec += 1000000;
        *sec -= 1;
     }
   
   /* In other words.. immediately. */
   if ( *sec < 0 )
     *sec = *usec = 0;
}



TIMER *add_timer( const char *name, float delay, void (*cb)( TIMER *timer ),
		int d0, int d1, int d2 )
{
   TIMER *t;
   struct timeval now;
   
//   debugf( "Timer: Add [%s] (%d)", name, delay );
   
   /* Check if we already have it in the list. */
   if ( name && name[0] != '*' )
     for ( t = timers; t; t = t->next )
       {
          if ( !strcmp( t->name, name ) )
            break;
       }
   else
     t = NULL;
   
   if ( !t )
     {
        t = calloc( sizeof( TIMER ), 1 );
        t->name = strdup( name );
        t->next = timers;
        timers = t;
     }
   
   gettimeofday( &now, NULL );
   t->fire_at_sec = now.tv_sec + (int) (delay);
   t->fire_at_usec = now.tv_usec + (int) ((unsigned long long) (delay * 1000000) % 1000000);
   
   if ( t->fire_at_usec >= 1000000 )
     {
        t->fire_at_sec += 1;
        t->fire_at_usec -= 1000000;
     }
   
   t->callback = cb;
   t->data[0] = d0;
   t->data[1] = d1;
   t->data[2] = d2;
   
   return t;
}



void del_timer( const char *name )
{
   TIMER *t;
   
   while( 1 )
     {
        for ( t = timers; t; t = t->next )
          if ( !strcmp( name, t->name ) )
            {
               unlink_timer( t );
               free_timer( t );
               break;
            }
        
        if ( !t )
          return;
     }
}



int atcp_authfunc( char *seed )
{
   int a = 17;
   int len = strlen( seed );
   int i;
   
   for ( i = 0; i < len; i++ )
     {
	int n = seed[i] - 96;
	
	if ( i % 2 == 0 )
	  a += n * ( i | 0xd );
	else
	  a -= n * ( i | 0xb );
     }
   
   return a;
}



void handle_atcp( char *msg )
{
   char act[256];
   char opt[256];
   char *body;
   int we_control_it;
   
   DEBUG( "handle_atcp" );
   
   we_control_it = strcmp( atcp_login_as, "none" );
   
   body = strchr( msg, '\n' );
   
   if ( body )
     body += 1;
   
   msg = get_string( msg, act, 256 );
   
   if ( !strcmp( act, "Auth.Request" ) && we_control_it )
     {
	msg = get_string( msg, opt, 256 );
	
	a_on = 0;
	
	if ( !strncmp( opt, "CH", 2 ) )
	  {
	     char buf[1024];
	     char sb_atcp[] = { IAC, SB, ATCP, 0 };
	     
	     if ( body )
	       {
		  if ( !atcp_login_as[0] || !strcmp( atcp_login_as, "default" ) )
		    sprintf( atcp_login_as, "MudBot %d.%d", main_version_major, main_version_minor );
		  
		  sprintf( buf, "%s" "auth %d %s" "%s",
			   sb_atcp, atcp_authfunc( body ),
			   atcp_login_as, iac_se );
		  send_to_server( buf );
	       }
	     else
	       debugf( "atcp: No body sent to authenticate." );
	  }
	
	if ( !strncmp( opt, "ON", 2 ) )
	  {
//	     sprintf( buf, "%s" "file get javaclient_settings2 Settings" "%s",
//		      sb_atcp, se_atcp );
//	     send_to_server( buf );
	     
	     debugf( "atcp: Authenticated." );
	     
	     a_on = 1;
	  }
	if ( !strncmp( opt, "OFF", 3 ) )
	  {
	     a_on = 0;
	     debugf( "atcp: Authentication failed." );
	  }
     }
   
   /* Bleh, has a newline after it too. */
   else if ( !strncmp( act, "Char.Vitals", 10 ) )
     {
	if ( !a_on )
	  a_on = 1;
	
	if ( !body )
	  {
	     debugf( "No Body!" );
	     return;
	  }
	
	sscanf( body, "H:%d/%d M:%d/%d E:%d/%d W:%d/%d NL:%d/100",
		&a_hp, &a_max_hp, &a_mana, &a_max_mana,
		&a_end, &a_max_end, &a_will, &a_max_will, &a_exp );
     }
   
   else if ( !strncmp( act, "Char.Name", 9 ) )
     {
	if ( !a_on )
	  a_on = 1;
	
	sscanf( msg, "%s", a_name );
	strcpy( a_title, body );
     }
   
   else if ( !strncmp( act, "Client.Compose", 15 ) && we_control_it )
     {
#if defined( FOR_WINDOWS )
	void win_composer_contents( char *string );
	
	if ( body && body[0] )
	  {
	     clientf( "\r\n" );
	     clientfb( "Composer's contents received. Type `edit and load the buffer." );
	     show_prompt( );
	     win_composer_contents( body );
	  }
#endif
     }
   
   
//   else
//     debugf( "[%s[%s]%s]", act, body, msg );
}


void client_telnet( char *buf, char *dst, int *bytes )
{
   const char do_mxp[] = { IAC, DO, TELOPT_MXP, 0 };
   const char dont_mxp[] = { IAC, DONT, TELOPT_MXP, 0 };
   
   static char iac_string[3];
   static int in_iac;
   
   int i, j;
   
   DEBUG( "client_telnet" );
   
   for ( i = 0, j = 0; i < *bytes; i++ )
     {
	/* Interpret As Command! */
	if ( buf[i] == (char) IAC )
	  {
	     in_iac = 1;
	     
	     iac_string[0] = buf[i];
	     iac_string[1] = 0;
	     iac_string[2] = 0;
	     
	     continue;
	  }
	
	if ( in_iac )
	  {
	     iac_string[in_iac] = buf[i];
	     
	     /* These need another byte. Wait for one more... */
	     if ( buf[i] == (char) WILL ||
		  buf[i] == (char) WONT ||
		  buf[i] == (char) DO ||
		  buf[i] == (char) DONT ||
		  buf[i] == (char) SB )
	       {
		  in_iac = 2;
		  continue;
	       }
	     
	     /* We have everything? Let's see what, then. */
	     
	     if ( !memcmp( iac_string, do_mxp, 3 ) )
	       {
		  mxp_enabled = 1;
		  debugf( "mxp: Supported by your Client!" );
		  
		  if ( default_mxp_mode )
		    mxp_tag( default_mxp_mode );
		  
		  module_mxp_enabled( );
	       }
	     
	     else if ( !memcmp( iac_string, dont_mxp, 3 ) )
	       {
		  mxp_enabled = 0;
		  debugf( "mxp: Unsupported by your client." );
	       }
	     
	     else
	       {
		  /* Nothing we know about? Send it further then. */
		  dst[j++] = iac_string[0];
		  dst[j++] = iac_string[1];
		  if ( in_iac == 2 )
		    dst[j++] = iac_string[2];
	       }
	     
	     in_iac = 0;
	     
	     continue;
	  }
	
	/* Copy, one by one. */
	dst[j++] = buf[i];
     }
   
   *bytes = j;
}


int check_sub_telnet( char *sub )
{
   if ( sub[0] == (char) ATCP )
     {
	handle_atcp( sub+1 );
	/* Either it's on, or we'll want it on. */
	return a_on || strcmp( atcp_login_as, "none" );
     }
   else
     debugf( "Unknown IAC/SB IAC/SE sequence." );
   
   return 0;
}



/* A function that gets a word, or string between two quotes. */
char *get_string( const char *argument, char *arg_first, int max )
{
   char cEnd = ' ';
   
   DEBUG( "get_string" );
   
   max--;
   
   while ( isspace( *argument ) )
     argument++;
   
   if ( *argument == '"' )
     cEnd = *argument++;
   
   while ( *argument != '\0' && *argument != '\n' && *argument != '\r' && max )
     {
	if ( *argument == cEnd )
	  {
	     argument++;
	     break;
	  }
	*arg_first = *argument;
	arg_first++;
	argument++;
	max--;
     }
   
   *arg_first = '\0';
   
   while ( isspace( *argument ) )
     argument++;
   
   return (char *) argument;
}



void mxp( char *string, ... )
{
   char buf [ 4096 ];
   
   if ( !mxp_enabled )
     return;
   
   va_list args;
   va_start( args, string );
   vsnprintf( buf, 4096, string, args );
   va_end( args );
   
   clientf( buf );
}


int mxp_tag( int tag )
{
   if ( !mxp_enabled )
     return 0;
   
   if ( tag == TAG_DEFAULT )
     {
	if ( default_mxp_mode )
	  tag = default_mxp_mode;
	else
	  tag = 7;
     }
   
   if ( tag == TAG_NOTHING || tag < 0 )
     return default_mxp_mode;
   
   clientff( "\33[%dz", tag );
   return 1;
}


int mxp_stag( int tag, char *dest )
{
   *dest = 0;
   
   if ( !mxp_enabled )
     return 0;
   
   if ( tag == TAG_DEFAULT )
     {
	if ( default_mxp_mode )
	  tag = default_mxp_mode;
	else
	  tag = 7;
     }
   
   if ( tag == TAG_NOTHING || tag < 0 )
     return default_mxp_mode;
   
   sprintf( dest, "\33[%dz", tag );
   return 1;
}


void do_test( )
{ 
   /*
   void process_buffer( char *buf, int bytes );
   char buf[4096*4096];
   int i;
   
//   random( );
   
   for ( i = 0; i < 4096*4096; i++ )
     buf[i] = 'a';
   
   buf[0] = (char) IAC;
   buf[1] = (char) SB;
   buf[2] = (char) ATCP;
   buf[4096*2047-128] = IAC;
   buf[4096*2047-127] = SE;
   
   process_buffer( buf, 4096*2048 );*/
}



void force_off_mccp( )
{
#if !defined( DISABLE_MCCP )
   /* Mccp. */
   if ( compressed )
     {
	inflateEnd( zstream );
	compressed = 0;
	debugf( "mccp: Forced off." );
     }
#endif
}


void process_client_line( char *buf )
{
   /* If not connected, parse differently. */
   if ( !server )
     {
	char hostname[256];
	char portbuf[256];
	char *p;
	int port;
	int sock;
	
	if ( strncmp( buf, "connect ", 8 ) ||
	     !( p = get_string( buf+8, hostname, 256 ) ) ||
	     !hostname[0] ||
	     !( p = get_string( p, portbuf, 256 ) ) ||
	     !portbuf[0] ||
	     !( port = atoi( portbuf ) ) )
	  {
	     clientf( C_B "No no... Look here. Syntax:\r\n" C_0
		      C_W "  connect <hostname> <port>\r\n" C_0
		      C_B "Example: connect imperian.com 23\r\n" C_0 );
	     return;
	  }
	
	debugf( "Connecting to: %s %d.", hostname, port );
	clientf( C_B "Connecting... " C_0 );
	
	sock = mb_connect( hostname, port );
	
	if ( sock < 0 )
	  {
	     debugf( "Failed (%s)", get_connect_error( ) );
	     clientff( C_B "%s.\r\n" C_0, get_connect_error( ) );
	     assign_server( 0 );
	     return;
	  }
	
	debugf( "Connected." );
	clientf( C_B "Done.\r\n" C_0 );
	clientfb( "Send `help to get some help." );
	
	strcpy( server_hostname, hostname );
	
	assign_server( sock );
	return;
     }
   
   if ( buf[0] == '`' ) /* Command */
     {
	char *b;
	
	/* Strip the newline. */
	for ( b = buf; *b; b++ )
	  if ( *b == '\n' )
	    {
	       *b = 0;
	       break;
	    }
	
	if ( !strcmp( buf, "`quit" ) )
	  {
	     clientfb( "Farewell." );
	     exit( 0 );
	  }
	else if ( !strcmp( buf, "`disconnect" ) )
	  {
	     /* This will c_close it and set to 0. */
	     assign_server( 0 );
	     
	     force_off_mccp( );
	     
	     clientfb( "Disconnected." );
	     clientfb( "Syntax: connect hostname portnumber" );
	     memset( &last_prompt, 0, sizeof( LINE ) );
	  }
	else if ( !strcmp( buf, "`reboot" ) )
	  {
#if defined( FOR_WINDOWS )
	     clientfb( "Rebooting on Windows will just result in a very happy crash. Don't." );
#else
	     char buf2[1024];
	     
	     if ( compressed )
	       clientfb( "Can't reboot, while server is sending compressed data. Use `mccp stop, first." );
	     else
	       {
		  clientfb( "Copyover in progress." );
		  debugf( "Attempting a copyover." );
		  
		  copy_over( "copyover" );
		  
		  sprintf( buf2, "Failed copyover!" );
		  clientfb( buf2 );
	       }
#endif
	  }
	else if ( !strcmp( buf, "`mccp start" ) )
	  {
	     char mccp_start[] = 
	       { IAC, DO, TELOPT_COMPRESS2, 0 };
	     
#if defined( DISABLE_MCCP )
	     clientfb( "The MCCP protocol has been internally disabled." );
	     clientfb( "Recompile the sources with a zlib library linked.." );
	     return;
#endif
	     
	     if ( safe_mode )
	       {
		  clientfb( "Not while in safe mode." );
	       }
	     else if ( !compressed )
	       {	     
		  clientfb( "Attempting to start decompression." );
		  send_to_server( mccp_start );
		  verbose_mccp = 1;
		  return;
	       }
	     else
	       {
		  clientfb( "Compression already started by server." );
	       }
	  }
	else if ( !strcmp( buf, "`mccp stop" ) )
	  {
	     char mccp_stop[] = 
	       { IAC, DONT, TELOPT_COMPRESS2, 0 };
	     
	     clientfb( "Attempting to stop decompression." );
	     send_to_server( mccp_stop );
	     verbose_mccp = 1;
	     
	     return;
	  }
	else if ( !strncmp( buf, "`mccp", 5 ) )
	  {
	     clientfb( "Use either `mccp start, or `mccp stop." );
	  }
	else if ( !strcmp( buf, "`atcp" ) )
	  {
	     clientfb( "ATCP info:" );
	     clientff( "Logged on: " C_G "%s" C_0 ".\r\n",
		       a_on ? "Yes" : "No" );
	     
	     if ( a_on )
	       {
		  clientff( "Name: " C_G "%s" C_0 ".\r\n", a_name[0] ? a_name : "Unknown" );
		  clientff( "Full name: " C_G "%s" C_0 ".\r\n", a_title[0] ? a_title : "Unknown" );
		  clientff( "H:" C_G "%d" C_0 "/" C_G "%d" C_0 "  "
			    "E:" C_G "%d" C_0 "/" C_G "%d" C_0 ".\r\n",
			    a_hp, a_max_hp, a_end, a_max_end );
		  clientff( "M:" C_G "%d" C_0 "/" C_G "%d" C_0 "  "
			    "W:" C_G "%d" C_0 "/" C_G "%d" C_0 ".\r\n",
			    a_mana, a_max_mana, a_will, a_max_will );
		  clientff( "NL:" C_G "%d" C_0 "/" C_G "100" C_0 ".\r\n",
			    a_exp );
	       }
	  }
	else if ( !strcmp( buf, "`mods" ) )
	  {
	     show_modules( );
	  }
	else if ( !strcmp( buf, "`shared" ) )
	  {
	     struct shared_memory_data *sm;
	     
	     clientfb( "Shared memory:" );
	     
	     for ( sm = shared_memory_table; sm; sm = sm->next )
	       clientff( C_B "\"%s\"" C_0 " (" C_G "%d" C_0 " bytes at " C_G "0x%x" C_0 ", in module " C_W "%s" C_0 ")\r\n",
			 sm->name, sm->size, sm->pointer, sm->module->name );
	  }
	else if ( !strncmp( buf, "`load", 5 ) )
	  {
	     if ( buf[5] == ' ' && buf[6] )
	       load_module( buf+6 );
	     else
	       clientfb( "What module to load? Specify a file name." );
	  }
	else if ( !strncmp( buf, "`unload", 7 ) )
	  {
	     if ( buf[7] == ' ' && buf[8] )
	       do_unload_module( buf+8 );
	     else
	       clientfb( "What module to unload? Use `mods for a list." );
	  }
	else if ( !strncmp( buf, "`reload", 7 ) )
	  {
	     if ( buf[7] == ' ' && buf[8] )
	       do_reload_module( buf+8 );
	     else
	       clientfb( "What module to reload? Use `mods for a list." );
	  }
	else if ( !strcmp( buf, "`timers" ) )
          {
             TIMER *t;
             struct timeval now;
             int sec, usec;
             
             gettimeofday( &now, NULL );
             
             if ( !timers )
               clientfb( "No timers." );
             else
               {
                  clientfb( "Timers:" );
                  for ( t = timers; t; t = t->next )
                    {
                       clientff( " - At: %d.%6d\r\n", t->fire_at_sec, t->fire_at_usec );
                       sec = t->fire_at_sec - now.tv_sec;
                       usec = t->fire_at_usec - now.tv_usec;
                       if ( usec < 0 )
                         usec += 1000000, sec -= 1;
                       clientff( " - '%s' (%d.%6d)\r\n", t->name, sec, usec, -1 );
                    }
               }
          }
	else if ( !strcmp( buf, "`desc" ) )
	  {
	     if ( !descs )
	       clientfb( "No descriptors... ?! (impossible)" );
	     else
	       {
		  DESCRIPTOR *d;
		  
		  clientfb( "Descriptors:" );
		  for ( d = descs; d; d = d->next )
		    {
		       clientff( " - " C_B "%s" C_0 " (%s)\r\n",
				 d->name, d->description ? d->description : "No description" );
		       clientff( "   fd: " C_G "%d" C_0 " in: %s out: %s exc: %s\r\n",
				 d->fd,
				 d->callback_in ? C_G "Yes" C_0 : C_R "No" C_0,
				 d->callback_out ? C_G "Yes" C_0 : C_R "No" C_0,
				 d->callback_exc ? C_G "Yes" C_0 : C_R "No" C_0 );
		    }
	       }
	  }
	else if ( !strcmp( buf, "`status" ) )
	  {
	     clientfb( "Status:" );
	     
	     clientff( "Bytes sent: " C_G "%d" C_0 " (" C_G "%d" C_0 "Kb).\r\n",
		       bytes_sent, bytes_sent / 1024 );
	     clientff( "Bytes received: " C_G "%d" C_0 " (" C_G "%d" C_0 "Kb).\r\n",
		       bytes_received, bytes_received / 1024 );
	     clientff( "Uncompressed: " C_G "%d" C_0 " (" C_G "%d" C_0 "Kb).\r\n",
		       bytes_uncompressed, bytes_uncompressed / 1024 );
	     if ( bytes_uncompressed )
	       clientff( "Compression ratio: " C_G "%d%%" C_0 ".\r\n", ( bytes_received * 100 ) / bytes_uncompressed );
	     clientff( "MCCP: " C_G "%s" C_0 ".\r\n", compressed ? "On" : "Off" );
	     clientff( "ATCP: " C_G "%s" C_0 ".\r\n", a_on ? "On" : "Off" );
	  }
	else if ( !strncmp( buf, "`echo ", 6 ) )
	  {
	     if ( safe_mode )
	       {
		  clientfb( "Impossible in safe mode." );
	       }
	     else
	       {
		  void process_buffer( char *buf, int bytes );
		  char buf2[4096], *b = buf2;
		  char *p = buf + 6;
		  
		  /* Find the new line, and end the string there. */
		  while ( *p )
		    {
		       if ( *p == '$' )
			 *(b++) = '\n';
		       else if ( *p == '\n' || *p == '\r' )
			 break;
		       else
			 *(b++) = *p;
		       
		       p++;
		    }
		  *(b++) = '\n';
		  *b = 0;
		  
		  clientfb( "Processing buffer.." );
		  process_buffer( buf2, strlen( buf2 ) );
	       }
	  }
	else if ( !strcmp( buf, "`echo" ) )
	  {
	     clientfb( "Usage: `echo <string>" );
	  }
	else if ( !strncmp( buf, "`sendatcp", 9 ) )
	  {
	     const char sb_atcp[] = { IAC, SB, ATCP, 0 };
	     char buf[1024];
	     
	     sprintf( buf, "%s%s%s", sb_atcp, buf + 10, iac_se );
	     send_to_server( buf );
	  }
#if defined( FOR_WINDOWS )
	else if ( !strcmp( buf, "`edit" ) )
	  {
	     void win_show_editor( );
	     win_show_editor( );
	  }
#endif
	else if ( !strncmp( buf, "`license", 8 ) )
	  {
	     clientf( C_W " Copyright (C) 2004, 2005  Andrei Vasiliu\r\n"
		      "\r\n"
		      " This program is free software; you can redistribute it and/or modify\r\n"
		      " it under the terms of the GNU General Public License as published by\r\n"
		      " the Free Software Foundation; either version 2 of the License, or\r\n"
		      " (at your option) any later version.\r\n"
		      "\r\n"
		      " This program is distributed in the hope that it will be useful,\r\n"
		      " but WITHOUT ANY WARRANTY; without even the implied warranty of\r\n"
		      " MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the\r\n"
		      " GNU General Public License for more details.\r\n"
		      "\r\n"
		      " You should have received a copy of the GNU General Public License\r\n"
		      " along with this program; if not, write to the Free Software\r\n"
		      " Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA\r\n" C_0 );
	  }
	else if ( !strcmp( buf, "`ptime" ) )
	  {
	     show_processing_time = show_processing_time ? 0 : 1;
	     
	     if ( show_processing_time )
	       clientfb( "Enabled." );
	     else
	       clientfb( "Disabled." );
	  }
	else if ( !strcmp( buf, "`test" ) )
	  {
	     do_test( );
	  }
	else if ( !strcmp( buf, "`id" ) )
	  {
	     module_show_id( );
	  }
	else if ( !strcmp( buf, "`log" ) )
	  {
	     if ( logging )
	       {
		  clientfb( "Logging stopped." );
		  logff( NULL, "-= LOG ENDED =-" );
		  logging = 0;
	       }
	     else
	       {
		  logging = 1;
		  logff( NULL, "-= LOG STARTED =-" );
		  clientfb( "Logging started." );
	       }
	  }
	else if ( !strcmp( buf, "`help" ) )
	  {
	     clientff( C_B "[" C_R "MudBot v" C_G "%d" C_R "." C_G "%d"
		       C_R " Help" C_B "]\r\n" C_0,
		       main_version_major, main_version_minor );
	     clientfb( "Commands:" );
	     clientf( C_B
		      " `help       - This thing.\r\n"
		      " `reboot     - Copyover, keeping descriptors alive.\r\n"
		      " `disconnect - Disconnects, giving you a chance to connect again.\r\n"
		      " `mccp start - This will ask the server to begin compression.\r\n"
		      " `mccp stop  - Stop the Mud Client Compression Protocol.\r\n"
		      " `atcp       - Show any ATCP info.\r\n"
		      " `mods       - Show the modules currently built in.\r\n"
		      " `load <m>   - Attempt to load a module from a file 'm'.\r\n"
		      " `unload <m> - Unload the module named 'm'.\r\n"
		      " `reload <m> - Unload and attempt to reload a module named 'm'.\r\n"
		      " `timers     - Show all registered timers.\r\n"
		      " `desc       - Show all registered descriptors.\r\n"
		      " `status     - Show some things that might be useful.\r\n"
		      " `echo <s>   - Process a string, as if it came from the server.\r\n"
#if defined( FOR_WINDOWS )
		      " `edit       - Open the Editor.\r\n"
#endif
		      " `license    - GNU GPL notice.\r\n"
		      " `id         - Source Identification.\r\n"
		      " `log        - Toggle logging into the log.txt file.\r\n"
		      " `quit       - Ends the program, for good.\r\n" C_0 );
	     clientfb( "Rebooting or crashing will keep the connection alive." );
	     clientfb( "Everything in blue brackets belongs to the MudBot engine." );
	     clientfb( "Things in red brackets are module specific." );
	  }
	else
	  {
	     if ( !safe_mode )
	       {
		  if ( module_process_client_command( buf ) )
		    clientfb( "What?" );
	       }
	     else
	       clientfb( "Not while in safe mode." );
	  }
	
	show_prompt( );
     }
   else if ( buf[0] == '\33' && buf[1] == '[' && buf[2] == '1' && buf[3] == 'z' )
     {
	/* MXP line from the client. Parse it, but don't send it. */
	if ( safe_mode )
	  module_process_client_aliases( buf );
     }
   else
     {
	char *send = buf;
	
	/* A one character line? Imperian refuses to read them. */
	/* Kmud likes to send one char lines. */
	if ( !buf[1] && buf[0] == '\n' )
	  send = "\r\n";
	
	if ( safe_mode || !module_process_client_aliases( buf ) )
	  send_to_server( send );
     }
   
   return;
}



int process_client( void )
{
   static char *telsub_buffer, *telsub_p, *telsub_max;
   static char last_client_line[4096];
   static char iac_string[4];
   static int last_client_pos = 0;
   static int in_iac;
   static int in_sb;
   char buf[4096];
   int bytes, i;
   
   DEBUG( "process_client" );
   
   mb_section = "Processing client data";
   
   bytes = c_read( client->fd, buf, 4095 );
   
   if ( bytes < 0 )
     {
	debugf( "process_client: %s.", get_socket_error( NULL ) );
	return 1;
     }
   else if ( bytes == 0 )
     {
	debugf( "Client closed connection." );
	if ( server )
	  debugf( "Connection to server is still kept alive." );
	return 1;
     }
   
   /* In case something makes it crash, this lets us know where. */
   crash_buffer = buf;
   crash_buffer_len = 4096;
   
   log_bytes( "c->m", buf, bytes );
   
   for ( i = 0; i < bytes; i++ )
     {
	/* Interpret As Command! */
	if ( buf[i] == (char) IAC )
	  {
	     in_iac = 1;
	     
	     iac_string[0] = buf[i];
	     iac_string[1] = 0;
	     iac_string[2] = 0;
	     continue;
	  }
	
	if ( in_iac )
	  {
	     iac_string[in_iac] = buf[i];
	     
	     /* These need another byte. Wait for one more... */
	     if ( buf[i] == (char) WILL ||
		  buf[i] == (char) WONT ||
		  buf[i] == (char) DO ||
		  buf[i] == (char) DONT )
	       {
		  in_iac = 2;
		  continue;
	       }
	     
	     iac_string[in_iac+1] = 0;
	     in_iac = 0;
	     
	     /* We have everything? Let's see what, then. */
	     
	     if ( iac_string[1] == (char) DO && iac_string[2] == (char) TELOPT_MXP )
	       {
		  char start_mxp[] = { IAC, SB, TELOPT_MXP, IAC, SE, 0 };
		  
		  mxp_enabled = 1;
		  debugf( "mxp: Supported by your Client!" );
		  
		  clientf( start_mxp );
		  
		  if ( default_mxp_mode )
		    mxp_tag( default_mxp_mode );
		  
		  module_mxp_enabled( );
		  continue;
	       }
	     
	     else if ( iac_string[1] == (char) DONT && iac_string[2] == (char) TELOPT_MXP )
	       {
		  mxp_enabled = 0;
		  debugf( "mxp: Unsupported by your client." );
		  continue;
	       }
	     
	     else if ( iac_string[1] == (char) SB )
	       {
		  in_sb = 1;
		  continue;
	       }
	     
	     else if ( iac_string[1] == (char) SE && in_sb )
	       {
		  in_sb = 0;
		  
		  /* Flush any text first. */
		  if ( last_client_pos )
		    {
		       debugf( "Forced to flush unfinished client input." );
		       process_client_line( last_client_line );
		       last_client_line[0] = 0;
		       last_client_pos = 0;
		    }
		  
		  /* Handle sub negotiation. For now, just send it. */
		  send_to_server( (char *) iac_sb );
		  send_to_server( telsub_buffer );
		  send_to_server( (char *) iac_se );
		  shrink_buffer( &telsub_buffer, &telsub_p, &telsub_max );
		  continue;
	       }
	     
	     /* Else, send it. */
	     
	     /* Flush any text first. */
	     if ( last_client_pos )
	       {
		  debugf( "Forced to flush unfinished client input." );
		  process_client_line( last_client_line );
		  last_client_line[0] = 0;
		  last_client_pos = 0;
	       }
	     
	     process_client_line( iac_string );
	     continue;
	  }
	
	if ( in_sb )
	  {
	     static char s[2];
	     
	     s[0] = buf[i];
	     
	     add_buffer( s, &telsub_buffer, &telsub_p, &telsub_max );
	     continue;
	  }
	
	/* Anything usually gets dumped here. */
	/* Ignore \r's though. */
	if ( buf[i] != '\r' )
	  {
	     last_client_line[last_client_pos] = buf[i];
	     last_client_line[++last_client_pos] = 0;
	  }
	
	if ( buf[i] == '\n' || last_client_pos > 4096 - 4 )
	  {
	     last_client_line[last_client_pos] = '\r';
	     last_client_line[++last_client_pos] = 0;
	     
	     sent_something = 1;
	     
	     process_client_line( last_client_line );
	     
	     /* Clear the line. */
	     last_client_line[0] = 0;
	     last_client_pos = 0;
	  }
     }
   
   crash_buffer = NULL;
   
   return 0;
}



void empty_buffer( )
{
   *g_b = 0;
   if ( g_b != buffer_data )
     clientf( buffer_data );
   g_b = buffer_data;
}


/* Too repetitive. But performance is critical here, we can't make it a function. */
#define SEND_BYTES_IN_BUFFER( source ) if ( (source) ) { s = (source); while ( *s ) { *(g_b++) = *(s++); if ( g_b == g_blimit ) empty_buffer( ); } }

void print_buffer( char *src )
{
   char *s;
   
   SEND_BYTES_IN_BUFFER( src );
}



void print_line( LINE *line, int prompt )
{
   char *ending;
   char *s;
   int i;
   
   DEBUG( "print_line" );
   
   if ( strip_telnet_ga && prompt )
     ending = "";
   else
     ending = line->ending;
   
   /* Figure out which line this is. Fully gagged lines cease existing. */
   if ( !line->gag_ending || !line->gag_entirely ||
	( line->replace && *line->replace ) ||
	( line->suffix && *line->suffix ) ||
	( line->prefix && *line->prefix ) )
     {
	current_line++;
   
	/* First line (or prompt)? */
	if ( current_line == 1 && !sent_something )
	  add_newline = 1;
	
	sent_something = 0;
	
	if ( prompt > 0 )
	  current_line = 0;
     }
   
   /*
   if ( prompt > 0 )
     {
	if ( !current_line && !sent_something )
	  add_newline = 1;
	else
	  {
	     sent_something = 0;
	     current_line = 0;
	  }
     }
   else if ( prompt == 0 )
     {
	if ( !line->gag_ending || !line->gag_entirely ||
	     ( line->replace && *line->replace ) ||
	     ( line->suffix && *line->suffix ) )
	  current_line++;
	
	if ( line->len && current_line == 1 && !sent_something )
	  add_newline = 1;
	sent_something = 0;
     }*/
   
   /* Add a new line whenever this line/prompt comes right after the last one. */
   if ( add_newline )
     {
	add_newline = 0;
	if ( line->len != 0 )
	  {
	     SEND_BYTES_IN_BUFFER( "\r\n" );
	  }
     }
   
   /* Order:
    *  prefix, ..., [raw, inlines, printable]*len, ..., suffix, ending */
   
   SEND_BYTES_IN_BUFFER( line->prefix );
   
   if ( !line->gag_entirely )
     {
	SEND_BYTES_IN_BUFFER( line->replace );
     }
   
   if ( !line->gag_entirely && ( !line->replace || !*line->replace ) )
     {
	for ( i = 0; i < line->len; i++ )
	  {
	     if ( *line->rawp[i] && !line->gag_raw[i] )
	       {
		  SEND_BYTES_IN_BUFFER( line->rawp[i] );
	       }
	     
	     SEND_BYTES_IN_BUFFER( line->inlines[i] );
	     
	     if ( !line->gag_character[i] )
	       {
		  /* Just one byte here. */
		  *(g_b++) = line->line[i];
		  if ( g_b == g_blimit )
		    empty_buffer( );
	       }
	  }
	
	/* Don't forget raw/inlines from the trailing '\0'. */
	if ( *line->rawp[i] && !line->gag_raw[i] )
	  {
	     SEND_BYTES_IN_BUFFER( line->rawp[i] );
	  }
	
	SEND_BYTES_IN_BUFFER( line->inlines[i] );
     }
   
   SEND_BYTES_IN_BUFFER( line->suffix );
   
   if ( !line->gag_ending )
     {
	SEND_BYTES_IN_BUFFER( ending );
     }
}

#undef SEND_BYTES_IN_BUFFER


void clean_line( LINE *line )
{
   int i;
   
   DEBUG( "clean_line" );
   
   for ( i = 0; i <= line->len; i++ )
     {
	if ( line->inlines[i] )
	  {
	     free( line->inlines[i] );
	     line->inlines[i] = NULL;
	  }
	
	if ( line->gag_character[i] )
	  line->gag_character[i] = 0;
	if ( line->gag_raw[i] )
	  line->gag_raw[i] = 0;
     }
   
   for ( ; i < line->raw_len; i++ )
     {
	if ( line->gag_raw[i] )
	  line->gag_raw[i] = 0;
     }
   
   if ( line->gag_entirely )
     line->gag_entirely = 0;
   if ( line->gag_ending )
     line->gag_ending = 0;
   
   line->rawp[0] = line->raw;
   line->len = 0;
   line->raw_len = 0;
   
   shrink_buffer( &prefix_buffer, &prefix_p, &prefix_max );
   shrink_buffer( &suffix_buffer, &suffix_p, &suffix_max );
   shrink_buffer( &replace_buffer, &replace_p, &replace_max );
   
   line->prefix = prefix_buffer;
   line->suffix = suffix_buffer;
   line->replace = replace_buffer;
}



void process_buffer( char *raw_buf, int bytes )
{
   static char *telsub_buffer, *telsub_p, *telsub_max;
   static char iac_string[4];
   static int in_iac;
   static int in_sb;
   char *buf = raw_buf;
   static LINE line;
   int i;
   struct timeval tvold, tvnew, tvold2, tvnew2;
   static time_t t1, t2, t3, t4;
   int prompt_detected = 0;
   
   DEBUG( "process_buffer" );
   
   mb_section = "Processing buffer";
   crash_buffer = raw_buf;
   crash_buffer_len = INPUT_BUF;
   
   processing = 1;
   
   bytes_uncompressed += bytes;
   
   log_bytes( "s->m", raw_buf, bytes );
   
   if ( show_processing_time )
     gettimeofday( &tvold2, NULL );
   
   /*
    * 'line' will contain the stripped, printable line.
    * 'raw_line' will contain the line as it came from the server.
    * 'raw' will contain the stripped pieces between printable characters.
    * 'raw_offset' will show where those pieces start, for each character.
    * 'rawp' is a pointer instead of integer, but same as above.
    */
   
   line.rawp[0] = line.raw;
   line.prefix = prefix_buffer;
   line.suffix = suffix_buffer;
   line.replace = replace_buffer;
   
   t1 = t2 = t3 = t4 = 0;
   gettimeofday( &tvold, NULL );
//   debugf( "---" );
   
#define ADD_TO( timer ) gettimeofday( &tvnew, NULL ); (timer) += tvnew.tv_usec - tvold.tv_usec + ( tvnew.tv_sec - tvold.tv_sec ) * 1000000; tvold = tvnew;
   
   /* Break it into the structure. */
   for ( i = 0; i < bytes; i++ )
     {
	/* Interpret As Command! */
	if ( buf[i] == (char) IAC )
	  {
	     in_iac = 1;
	     
	     iac_string[0] = buf[i];
	     iac_string[1] = 0;
	     iac_string[2] = 0;
	     
	     continue;
	  }
	
	if ( in_iac )
	  {
	     iac_string[in_iac] = buf[i];
	     
	     /* These need another byte. Wait for one more... */
	     if ( buf[i] == (char) WILL ||
		  buf[i] == (char) WONT ||
		  buf[i] == (char) DO ||
		  buf[i] == (char) DONT )
	       {
		  in_iac = 2;
		  continue;
	       }
	     
	     iac_string[in_iac+1] = 0;
	     in_iac = 0;
	     
	     /* We have everything? Let's see what, then. */
	     if ( iac_string[1] == (char) WILL &&
		  iac_string[2] == (char) TELOPT_COMPRESS2 )
	       {
#if !defined( DISABLE_MCCP )
		  if ( !disable_mccp )
		    {
		       const char do_compress2[] =
			 { IAC, DO, TELOPT_COMPRESS2, 0 };
		       
		       /* Send it for ourselves. */
		       send_to_server( (char *) do_compress2 );
		       
		       debugf( "mccp: Sent IAC DO COMPRESS2." );
		    }
#else
		  debugf( "mccp: Internally disabled, ignoring." );
#endif
		  continue;
	       }
	     
	     else if ( iac_string[1] == (char) WILL &&
		       iac_string[2] == (char) ATCP &&
		       strcmp( atcp_login_as, "none" ) )
	       {
		  char buf[256];
		  char do_atcp[] = { IAC, DO, ATCP, 0 };
		  char sb_atcp[] = { IAC, SB, ATCP, 0 };
		  
		  /* Send it for ourselves. */
		  send_to_server( do_atcp );
		  
		  debugf( "atcp: Sent IAC DO ATCP." );
		  
		  if ( !atcp_login_as[0] || !strcmp( atcp_login_as, "default" ) )
		    sprintf( atcp_login_as, "MudBot %d.%d", main_version_major, main_version_minor );
		  
		  sprintf( buf, "%s" "hello %s\nauth 1\ncomposer 1\nchar_name 1\nchar_vitals 1\nroom_brief 0\nroom_exits 0" "%s",
			   sb_atcp, atcp_login_as, iac_se );
		  send_to_server( buf );
		  
		  if ( default_user[0] && default_pass[0] )
		    {
		       sprintf( buf, "%s" "login %s %s" "%s",
				sb_atcp, default_user, default_pass, iac_se );
		       send_to_server( buf );
		       debugf( "atcp: Requested login with '%s'.", default_user );
		    }
		  continue;
	       }
	     
	     else if ( iac_string[1] == (char) GA ||
		       iac_string[1] == (char) EOR )
	       {
		  prompt_detected = iac_string[1];
	       }
	     
	     else if ( iac_string[1] == (char) SB )
	       {
		  in_sb = 1;
		  continue;
	       }
	     
	     else if ( iac_string[1] == (char) SE && in_sb )
	       {
		  in_sb = 0;
		  
		  /* Check the contents, then MAYBE send it. */
		  if ( !check_sub_telnet( telsub_buffer ) )
		    {
		       print_buffer( (char *) iac_sb );
		       print_buffer( telsub_buffer );
		       print_buffer( (char *) iac_se );
		    }
		  shrink_buffer( &telsub_buffer, &telsub_p, &telsub_max );
		  
		  continue;
	       }
	     
	     /* Else, send it. */
	     else
	       {
		  print_buffer( iac_string );
		  continue;
	       }
	  }
	
	if ( in_sb )
	  {
	     static char s[2];
	     
	     s[0] = buf[i];
	     
	     add_buffer( s, &telsub_buffer, &telsub_p, &telsub_max );
	     continue;
	  }
	
	/* Check for the end. Either new line, prompt GA, or byte limit. */
	if ( buf[i] == '\n' || prompt_detected ||
	     line.raw_len == INPUT_BUF - 1 )
	  {
	     int prompt = prompt_detected;
	     prompt_detected = 0;
	     
	     /* End of the line/prompt/limit? Good! Process it and show it! */
	     
	     ADD_TO( t1 );
	     
	     if ( prompt )
	       {
		  line.ending[0] = (char) IAC;
		  line.ending[1] = prompt;
		  line.ending[2] = 0;
		  
		  prompt = 1;
	       }
	     else
	       {
		  if ( buf[i] == '\n' )
		    {
		       line.ending[0] = '\r';
		       line.ending[1] = '\n';
		       line.ending[2] = 0;
		       prompt = 0;
		    }
		  else
		    {
		       line.ending[0] = 0;
		       prompt = -1;
		    }
	       }
	     
	     line.line[line.len] = 0;
	     line.raw_line[line.raw_len] = 0;
	     line.raw[line.raw_len] = 0;
	     line.raw_offset[line.len+1] = 0;
	     
	     if ( prompt > 0 )
	       last_prompt = line;
	     
	     crash_line = &line;
	     
	     /* Let the modules do some processing on it, then print it. */
	     if ( prompt )
	       module_process_server_prompt( &line );
	     else
	       module_process_server_line( &line );
	     
	     print_line( &line, prompt );
	     
	     ADD_TO( t2 );
	     
	     clean_line( &line );
	     
	     ADD_TO( t4 );
	     
	     if ( show_prompt_again )
	       {
		  show_prompt_again = 0;
		  
		  sent_something = 1;
		  line = last_prompt;
		  line.rawp[0] = line.raw;
		  line.prefix = prefix_buffer;
		  line.suffix = suffix_buffer;
		  line.replace = replace_buffer;
		  module_process_server_prompt( &line );
		  print_line( &line, 1 );
		  clean_line( &line );
	       }
	     
	     crash_line = NULL;
	     
	     if ( prompt >= 0 )
	       continue;
	     
	     /* Don't continue, current character must not be skipped. */
	  }
	
	/* Ignore this one. */
	if ( buf[i] == '\r' )
	  continue;
	
	line.raw_line[line.raw_len] = buf[i];
	
	/* Is this character printable, or just raw data or color codes? */
	if ( buf[i] == '\33' )
	  line.within_color_code = 1;
	
	/* Put it where it belongs, never in both places. */
	if ( line.within_color_code || buf[i] < 32 )
	  line.raw[line.raw_len++] = buf[i];
	else
	  {
	     line.line[line.len++] = buf[i];
	     
	     line.raw[line.raw_len++] = 0;
	     line.raw_offset[line.len] = line.raw_len;
	     line.rawp[line.len] = line.raw + line.raw_offset[line.len];
	  }
	
	/* Color codes end with the 'm' character. Beware of other ANSI codes! */
	if ( line.within_color_code && buf[i] == 'm' )
	  line.within_color_code = 0;
     }
   
//   debugf( "t1: [%d] t2:[%d] t3:[%d] t4:[%d]", (int) t1, (int) t2, (int) t3, (int) t4 );
//   debugf( C_W "Total: [%d]" C_0, (int) (t1 + t2 + t3 + t4 ) );
   
   if ( show_processing_time )
     gettimeofday( &tvnew2, NULL );
   
   empty_buffer( );
   
   if ( show_processing_time )
     {
	int usec, sec;
	
	usec = tvnew2.tv_usec - tvold2.tv_usec;
	sec = tvnew2.tv_sec - tvold2.tv_sec;
	
	clientff( "(%d)", usec + ( sec * 1000000 ) );
     }
   
   processing = 0;
   
   mb_section = "Out of process_buffer";
   crash_buffer = NULL;
}



void show_prompt( )
{
   char *last_section;
   
   last_section = mb_section;
   mb_section = "Reparsing prompt";
   
   if ( processing )
     {
	show_prompt_again = 1;
     }
   else
     {
	LINE line;
	
	crash_line = &line;
	sent_something = 1;
	line = last_prompt;
	line.rawp[0] = line.raw;
	line.prefix = prefix_buffer;
	line.suffix = suffix_buffer;
	line.replace = replace_buffer;
	module_process_server_prompt( &line );
	print_line( &line, 1 );
	clean_line( &line );
	empty_buffer( );
	crash_line = NULL;
     }
   
   mb_section = last_section;
}



char *find_bytes( char *src, int src_bytes, char *find, int bytes )
{
   char *p;
   
   src_bytes -= bytes - 1;
   
   for ( p = src; src_bytes >= 0; src_bytes--, p++ )
     {
	if ( !memcmp( p, find, bytes ) )
	  return p;
     }
   
   return NULL;
}


#if defined( DISABLE_MCCP )
int mccp_decompress( char *src, int src_bytes )
{
   /* Normal data, with nothing compressed. Just move along... */
   process_buffer( src, src_bytes );
   return 0;
}

#else

int mccp_decompress( char *src, int src_bytes )
{
   static char c2_start[] = { IAC, SB, TELOPT_COMPRESS2, IAC, SE, 0 };
   static char c2_stop[] = { IAC, DONT, TELOPT_COMPRESS2, 0 };
   char *p;
   int status;
   char buf[INPUT_BUF];
   
   DEBUG( "mccp_decompress" );
   
   if ( !compressed )
     {
	/* Compressed data starts somewhere here? */
	if ( ( p = find_bytes( src, src_bytes, c2_start, 5 ) ) )
	  {
	     debugf( "mccp: Starting decompression." );
	     
	     if ( verbose_mccp )
	       {
		  clientfb( "Server is now sending compressed data." );
		  show_prompt( );
		  verbose_mccp = 0;
	       }
	     
	     /* Copy and process whatever is uncompressed. */
	     if ( p - src > 0 )
	       {
		  memcpy( buf, src, p - src );
		  process_buffer( buf, p - src );
	       }
	     
	     src_bytes -= ( p - src + 5 );
	     src = p + 5; /* strlen( c2_start ) = 5 */
	     
	     /* Initialize zlib. */
	     
	     zstream = calloc( sizeof( z_stream ), 1 );
	     zstream->zalloc = NULL;
	     zstream->zfree = NULL;
	     zstream->opaque = NULL;
	     zstream->next_in = Z_NULL;
	     zstream->avail_in = 0;
	     
	     if ( inflateInit( zstream ) != Z_OK )
	       {
		  debugf( "mccp: error at inflateInit." );
		  exit( 1 );
	       }
	     
	     compressed = 1;
	     
	     /* Nothing more after it? */
	     if ( !src_bytes )
	       return 0;
	  }
	else
	  {
	     /* Normal data, with nothing compressed. Just move along... */
	     process_buffer( src, src_bytes );
	     return 0;
	  }
     }
   
   /* We have compressed data, beginning at *src. */
   
   zstream->next_in = (Bytef *) src;
   zstream->avail_in = src_bytes;
   
   while ( zstream->avail_in )
     {
	zstream->next_out = (Bytef *) buf;
	zstream->avail_out = INPUT_BUF;
	
	status = inflate( zstream, Z_SYNC_FLUSH );
	
	if ( status != Z_OK && status != Z_STREAM_END )
	  {
	     switch ( status )
	       {
		case Z_DATA_ERROR:
		  debugf( "mccp: inflate: data error." ); break;
		case Z_STREAM_ERROR:
		  debugf( "mccp: inflate: stream error." ); break;
		case Z_BUF_ERROR:
		  debugf( "mccp: inflate: buf error." ); break;
		case Z_MEM_ERROR:
		  debugf( "mccp: inflate: mem error." ); break;
	       }
	     
	     compressed = 0;
	     clientfb( "MCCP error." ); 
	     send_to_server( c2_stop );
	     break;
	  }
	
	process_buffer( buf, INPUT_BUF - zstream->avail_out );
	
	if ( status == Z_STREAM_END )
	  {
	     compressed = 0;
	     debugf( "mccp: Decompression ended." );
	     
	     if ( verbose_mccp )
	       {
		  verbose_mccp = 0;
		  clientfb( "Server no longer sending compressed data." );
		  show_prompt( );
	       }
	     
	     /* If avail_in is not empty, we have uncompressed data. */
	     if ( zstream->avail_in )
	       {
		  memcpy( buf, zstream->next_in, zstream->avail_in );
		  status = zstream->avail_in;
	       }
	     else
	       status = 0;
	     
	     inflateEnd( zstream );
	     zstream->avail_in = 0;
	     
	     /* But warning! Uncompressed data may start compression again! */
	     if ( status )
	       {
		  /* Leave. Don't do anything else here, recursivity and
		   * global variables don't go well together. */
		  mccp_decompress( buf, status );
		  return 1;
	       }
	  }
     }
   
   return 1;
}
#endif



int process_server( void )
{
   char raw_buf[INPUT_BUF];
   int bytes;
   
   DEBUG( "process_server" );
   
   bytes = c_read( server->fd, raw_buf, INPUT_BUF );
   
   if ( bytes < 0 )
     {
	debugf( "process_server: %s.", get_socket_error( NULL ) );
	clientfb( "Error while reading from server..." );
	debugf( "Restarting." );
	force_off_mccp( );
	return 1;
     }
   else if ( bytes == 0 )
     {
	clientfb( "Server closed connection." );
	debugf( "Server closed connection." );
	force_off_mccp( );
	return 1;
     }
   
   bytes_received += bytes;
   
   /* Decompress if needed, and process. */
   mccp_decompress( raw_buf, bytes );
   
   return 0;
}



int init_socket( int port )
{
   DESCRIPTOR *desc;
   static struct sockaddr_in sa_zero;
   struct sockaddr_in sa;
   int fd, x = 1;
   
   if ( ( fd = socket( AF_INET, SOCK_STREAM, 0 ) ) < 0 )
     {
	debugf( "Init_socket: socket: %s.", get_socket_error( NULL ) );
	return -1;
     }
   
   if ( setsockopt( fd, SOL_SOCKET, SO_REUSEADDR,
		    (char *) &x, sizeof( x ) ) < 0 )
     {
	debugf( "Init_socket: SO_REUSEADDR: %s.", get_socket_error( NULL ) );
	c_close( fd );
	return -1;
     }
   
   sa	      = sa_zero;
   sa.sin_family   = AF_INET;
   sa.sin_port     = htons( port );
   
   if ( bind_to_localhost )
     sa.sin_addr.s_addr = inet_addr( "127.0.0.1" );
   
   if ( bind( fd, (struct sockaddr *) &sa, sizeof( sa ) ) < 0 )
     {
	debugf( "Init_socket: bind: %s.", get_socket_error( NULL ) );
	c_close( fd );
	return -1;
     }

   if ( listen( fd, 1 ) < 0 )
     {
	debugf( "Init_socket: listen: %s.", get_socket_error( NULL ) );
	c_close( fd );
	return -1;
     }
   
   /* Control descriptor. */
   desc = calloc( 1, sizeof( DESCRIPTOR ) );
   desc->name = strdup( "Control" );
   desc->description = strdup( "Listening port" );
   desc->mod = NULL;
   desc->fd = fd;
   desc->callback_in = fd_control_in;
   desc->callback_out = NULL;
   desc->callback_exc = NULL;
   add_descriptor( desc );
   
   if ( !control )
     control = desc;
   
   return fd;
}


void remove_newline( char *string )
{
   char *p = string;
   
   while( *p )
     {
	if ( *p == '\n' || *p == '\r' )
	  {
	     *p = '\0';
	     return;
	  }
	p++;
     }
}


void crash_report( FILE *fl )
{
   int i;
   
   fprintf( fl, "[MB]\n" );
   fprintf( fl, "Section - %s.\n", mb_section ? mb_section : "Unknown" );
   
   fprintf( fl, "[MOD]\n" );
   if ( !mod_section )
     fprintf( fl, "Section - Not in a module.\n" );
   else
     {
	fprintf( fl, "Section - %s.\n", mod_section );
	fprintf( fl, "Module - %s.\n", ( current_mod && current_mod->name ) ? current_mod->name : "Unknown" );
     }
   
   fprintf( fl, "[DESC]\n" );
   if ( !desc_name )
     fprintf( fl, "Section - Not in a descriptor.\n" );
   else
     {
	fprintf( fl, "Section - %s\n", desc_section ? desc_section : "Unknown..." );
	fprintf( fl, "Descriptor - %s.\n", desc_name );
     }
   
   fprintf( fl, "[Buffer:]\n" );
   if ( crash_buffer )
     {
	fprintf( fl, "\"" );
	for ( i = 0; i < crash_buffer_len && crash_buffer[i]; i++ )
	  {
	     if ( isprint( crash_buffer[i] ) )
	       fprintf( fl, "%c", crash_buffer[i] );
	     else
	       fprintf( fl, "[%d]", (int) crash_buffer[i] );
	  }
	fprintf( fl, "\"\n" );
	if ( i == crash_buffer_len )
	  fprintf( fl, "Going out of bounds!\n" );
     }
   
   if ( crash_line )
     {
	fprintf( fl, "[Line Structure:]\n" );
	
	fprintf( fl, "Line - \"%s\"\n", crash_line->line );
	fprintf( fl, "Length - %d (raw %d)\n", crash_line->len, crash_line->raw_len );
     }
   
   fprintf( fl, "[History:]\n" );
   
   for ( i = 0; i < 6; i++ )
     {
	if ( !debug[i] )
	  break;
	fprintf( fl, " (%d) %s\n", i, debug[i] );
     }
}



void sig_segv_handler( int sig )
{
   /* Crash for good, if something bad happens here, too. */
   signal( sig, SIG_DFL );
   
   debugf( "Eep! Segmentation fault!" );
   
   crash_report( stdout );
   
/*   debugf( "History:" );
   for ( i = 0; i < 6; i++ )
     {
	if ( !debug[i] )
	  break;
	debugf( " (%d) %s", i, debug[i] );
     }*/
   
#if !defined( FOR_WINDOWS )
   if ( !client || !server )
     {
	debugf( "No client or no server. No reason to enter safe mode." );
	raise( sig );
	return;
     }
   
   debugf( "Attempting to keep connection alive." );
   
   if ( compressed )
     {
	char mccp_stop[] = { IAC, DONT, TELOPT_COMPRESS2 };
	
	debugf( "Warning! Server is sending compressed data, right now!" );
	debugf( "Attempting to send IAC DONT COMPRESS2, but might not work." );
	
	send_to_server( mccp_stop );
	
	force_off_mccp( );
     }
   
   /* Go in safe mode, so the connection can be kept alive until something is done. */
   copy_over( "safemode" );
   
   debugf( "Safe mode failed, nothing else I can do..." );
   raise( sig );
   exit( 1 );
#endif
}



#if defined( FOR_WINDOWS )

/* Windows: mudbot_init() */

void mudbot_init( int port )
{
   default_listen_port = port;
   
   /* Load all modules, and register them. */
   modules_register( );
   
   /* Initialize all modules. */
   module_init_data( );
}

#else

/* Others: main_loop() and main() */

void main_loop( )
{
   struct timeval pulsetime;
   fd_set in_set;
   fd_set out_set;
   fd_set exc_set;
   DESCRIPTOR *d, *d_next;
   int maxdesc = 0;
   
   while( 1 )
     {
	FD_ZERO( &in_set  );
	FD_ZERO( &out_set );
	FD_ZERO( &exc_set );
	
	/* What descriptors do we want to select? */
	for ( d = descs; d; d = d->next )
	  {
	     if ( d->fd < 1 )
	       continue;
	     
	     if ( d->callback_in )
	       FD_SET( d->fd, &in_set );
	     if ( d->callback_out )
	       FD_SET( d->fd, &out_set );
	     if ( d->callback_exc )
	       FD_SET( d->fd, &exc_set );
	     
	     if ( maxdesc < d->fd )
	       maxdesc = d->fd;
	  }
	
	/* If there's one or more timers, don't sleep more than 0.25 seconds. */
        if ( timers )
          {
             get_first_timer( &pulsetime.tv_sec, &pulsetime.tv_usec );
          }
        
	if ( select( maxdesc+1, &in_set, &out_set, &exc_set, timers ? &pulsetime : NULL ) < 0 )
	  {
	     if ( errno != EINTR )
	       {
		  debugerr( "main_loop: select: poll" );
		  exit( 1 );
	       }
	     else
	       continue;
	  }
	
	mb_section = "Checking timers";
	/* Check timers. */
	check_timers( );
	mb_section = NULL;
	
	DEBUG( "main_loop - descriptors" );
	
	/* Go through the descriptor list. */
	for ( d = descs; d; d = d_next )
	  {
	     d_next = d->next;
	     
	     /* Do we have a valid descriptor? */
	     if ( d->fd < 1 )
	       continue;
	     
	     desc_name = d->name;
	     
	     current_descriptor = d;
	     
	     desc_section = "Reading from...";
	     if ( d->callback_in && FD_ISSET( d->fd, &in_set ) )
	       (*d->callback_in)( d );
	     
	     if ( !current_descriptor )
	       continue;
	     
	     desc_section = "Writing to...";
	     if ( d->callback_out && FD_ISSET( d->fd, &out_set ) )
	       (*d->callback_out)( d );
	     
	     if ( !current_descriptor )
	       continue;
	     
	     desc_section = "Exception handler at...";
	     if ( d->callback_exc && FD_ISSET( d->fd, &exc_set ) )
	       (*d->callback_exc)( d );
	  }
	desc_name = NULL;
     }
}



int main( int argc, char **argv )
{
   int what = 0, help = 0;
   int i;
   
   /* We'll need this for a copyover. */
   if ( argv[0] )
     strcpy( exec_file, argv[0] );
   
   /* Parse command-line options. */
   for ( i = 1; i < argc; i++ )
     {
	if ( !what )
	  {
	     if ( !strcmp( argv[i], "-p" ) || !strcmp( argv[i], "--port" ) )
	       what = 1;
	     else if ( !strcmp( argv[i], "-c" ) || !strcmp( argv[i], "--copyover" ) )
	       what = 2, copyover = 1;
	     else if ( !strcmp( argv[i], "-s" ) || !strcmp( argv[i], "--safemode" ) )
	       what = 2, copyover = 2;
	     else if ( !strcmp( argv[i], "-h" ) || !strcmp( argv[i], "--help" ) )
	       what = 5;
	     else
	       help = 1;
	  }
	else
	  {
	     if ( what == 1 )
	       {
		  default_listen_port = atoi( argv[i] );
		  if ( default_listen_port < 1 || default_listen_port > 65535 )
		    {
		       debugf( "Port number invalid." );
		       help = 1;
		    }
	       }
	     else if ( what == 2 )
	       {
		  DESCRIPTOR *desc;
		  
		  /* Control descriptor. */
		  desc = calloc( 1, sizeof( DESCRIPTOR ) );
		  desc->name = strdup( "Control" );
		  desc->description = strdup( "Recovered listening port" );
		  desc->mod = NULL;
		  desc->fd = atoi( argv[i] );
		  desc->callback_in = fd_control_in;
		  desc->callback_out = NULL;
		  desc->callback_exc = NULL;
		  add_descriptor( desc );
		  
		  control = desc;
		  
		  what = 3;
		  continue;
	       }
	     else if ( what == 3 )
	       {
		  assign_client( atoi( argv[i] ) );
		  what = 4;
		  continue;
	       }
	     else if ( what == 4 )
	       {
		  assign_server( atoi( argv[i] ) );
	       }
	     else if ( what == 5 )
	       {
		  help = 1;
	       }
	     what = 0;
	  }
     }
   
   if ( help || what )
     {
	debugf( "Usage: %s [-p port] [-h]", argv[0] );
	return 1;
     }
   
   if ( copyover )
     {
	/* Recover from a copyover. */
	
	if ( control->fd < 1 || client->fd < 1 || server->fd < 1 )
	  {
	     debugf( "Couldn't recover from a %s, as some invalid arguments were passed.",
		     copyover == 1 ? "copyover" : "crash" );
	     return 1;
	  }
	
	if ( copyover == 1 )
	  {
	     debugf( "Copyover finished. Initializing, again." );
	     clientfb( "Initializing." );
	  }
	else if ( copyover == 2 )
	  {
	     debugf( "Recovering from a crash, starting in safe mode." );
	     clientf( "\r\n" );
	     clientfb( "Recovering from a crash, starting in safe mode." );
	     clientfb( "Use `reboot to start again, normally." );
	     safe_mode = 1;
	  }
     }
   
   if ( !safe_mode )
     {
	/* Signal handling. */
	signal( SIGSEGV, sig_segv_handler );
	
	/* Load and register all modules. */
	modules_register( );
	
	/* Initialize all modules. */
	module_init_data( );
     }
   
   if ( copyover == 1 )
     clientfb( "Copyover successful, entering main loop." );
   
   if ( !control )
     {
	debugf( "No ports to listen on! Define at least one." );
	return 1;
     }
   
   /* Look for a main_loop in a module. */
     {
	MODULE *module;
	
	for ( module = modules; module; module = module->next )
	  {
	     if ( !module->main_loop )
	       continue;
	     
	     debugf( "Using a module to enter main loop. All ready." );
	     (*module->main_loop)( argc, argv );
	     
	     return 0;
	  }
     }
   
   /* If it wasn't found, use ours. */
   while( 1 )
     {
	debugf( "Entering main loop. All ready." );
	main_loop( );
     }
}

#endif


/*
 * Extracts a word (^) or zone (*) used in the most recent trigger check.
 * This ^ is ^ trigger * won't ^ too ^ things.
 * Due to checking in reverse after *, wildcards are numbered as follows:
 *      1    2         0       4     3
 */

void extract_wildcard( int nr, char *dest, int max )
{
   char *s, *d;
   
   /* Impossible combinations are always possible. */
   if ( nr > wildcard_limit )
     {
	if ( max > 0 )
	  *dest = 0;
	return;
     }
   
   s = wildcards[nr][0];
   d = dest;
   
   while ( max > 1 && s < wildcards[nr][1] )
     *(d++) = *(s++), max--;
   
   if ( max > 0 )
     *d = 0;
}


/*
 * Checks a string to see if it matches a trigger string.
 * String "Hello world!" matches trigger "Hel*orld!".
 * String "Hello world!" matches trigger "Hello ^!". (single word)
 * 
 * Returns 0 if the strings match, 1 if not.
 */

int cmp( char *trigger, char *string )
{
   char *t, *s;
   int reverse = 0, w = 1;
   char *w_start[16], *w_stop[16];
   
   DEBUG( "trigger_cmp" );
   
   /* We shall begin from the start line. */
   t = trigger, s = string;
   
   /* Ready.. get set.. Go! */
   while ( 1 )
     {
	/* Are we checking in reverse? */
	if ( !reverse )
	  {
	     /* The end? */
	     if ( !*t && !*s )
	       break;
	     
	     /* One got faster to the end? */
	     if ( ( !*t || !*s ) && *t != '*' )
	       return 1;
	  }
	else
	  {
	     /* End of reverse? */
	     if ( t >= trigger && *t == '*' )
	       break;
	     
	     /* No '*' found? */
	     if ( s < string )
	       return 1;
	  }
	
	if ( *t == '^' )
	  {
	     if ( !reverse )
	       {
		  w_start[w] = s;
		  while ( isalnum( *s ) )
		    s++;
		  t++;
		  w_stop[w] = s;
	       }
	     else
	       {
		  w_stop[w] = s + 1;
		  while( s >= string && isalnum( *s ) )
		    s--;
		  t--;
		  w_start[w] = s + 1;
	       }
	     
	     if ( ++w > 15 )
	       w = 15;
	     
	     continue;
	  }
	
	else if ( *t == '*' )
	  {
	     /* Wildcard found, reversing search. */
	     reverse = 1;
	     
	     w_start[0] = s;
	     
	     /* Move them at the end. */
	     while ( *t ) t++;
	     while ( *s ) s++;
	  }
	else if ( *t != *s )
	  {
	     /* Chars differ, strings don't match. */
	     return 1;
	  }
	
	/* Run. Backwards if needed. */
	if ( !reverse )
	  t++, s++;
	else
	  t--, s--;
     }
   
   /* A match! Make the wildcards official. */
   
   wildcards[0][0] = reverse ? w_start[0] : 0;
   wildcards[0][1] = reverse ? s + 1 : 0;
   
   wildcard_limit = w - 1;
   
   while ( w > 1 )
     {
	w--;
	wildcards[w][0] = w_start[w];
	wildcards[w][1] = w_stop[w];
     }
   
   return 0;
}


void share_memory( char *name, void *pointer, int size )
{
   struct shared_memory_data *sm, *dest;
   
   if ( !current_mod )
     {
	debugf( "Request for share memory with no module known." );
	return;
     }
   
   /* Check for an existing entry. */
   for ( sm = shared_memory_table; sm; sm = sm->next )
     if ( sm->module == current_mod && !strcmp( name, sm->name ) )
       break;
   
   if ( sm )
     {
	sm->pointer = pointer;
	sm->size = size;
	
	return;
     }
   
   sm = calloc( 1, sizeof( struct shared_memory_data ) );
   
   sm->next = shared_memory_table;
   shared_memory_table = sm;
   
   sm->module = current_mod;
   sm->name = strdup( name );
   sm->pointer = pointer;
   sm->size = size;
   
   dest = sm;
   
   /* Check to see if there's another module with that name/size,
    * to copy the initial data from. */
   for ( sm = shared_memory_table; sm; sm = sm->next )
     if ( sm->module != current_mod && !strcmp( name, sm->name ) && sm->size == size )
       {
	  memcpy( dest->pointer, sm->pointer, size );
	  dest->pointer_to_string = sm->pointer_to_string;
	  
	  break;
       }
}


/* We don't want pointers pointing to a memory zone from an unloaded module! */
void shared_memory_is_pointer_to_string( char *name )
{
   struct shared_memory_data *sm;
   
   for ( sm = shared_memory_table; sm; sm = sm->next )
     if ( sm->size == sizeof( char * ) && !strcmp( name, sm->name ) )
       sm->pointer_to_string = 1;
}


void update_shared_memory( MODULE *module )
{
   struct shared_memory_data *sm_source, *sm_dest;
   char *s, *d;
   int i, size;
   
   if ( !module )
     return;
   
   for ( sm_source = shared_memory_table; sm_source; sm_source = sm_source->next )
     if ( sm_source->module == module )
       {
	  s = sm_source->pointer;
	  size = sm_source->size;
	  
	  for ( sm_dest = shared_memory_table; sm_dest; sm_dest = sm_dest->next )
	    {
	       /* Modify other modules, not this one. */
	       if ( sm_dest->module == module )
		 continue;
	       
	       /* Size and name must match. */
	       if ( size != sm_dest->size || strcmp( sm_source->name, sm_dest->name ) )
		 continue;
	       
	       /* Somewhat optimized comparison. */
	       d = sm_dest->pointer;
	       
	       for ( i = 0; i < size; i++ )
		 if ( *(s+i) != *(d+i) )
		   {
		      memcpy( d, s, size );
		      break;
		   }
	    }
       }
}


void remove_shared_memory_by_module( MODULE *module )
{
   struct shared_memory_data *sm, *last_sm, *sm_next;
   
   while ( shared_memory_table && shared_memory_table->module == module )
     {
	sm = shared_memory_table;
	if ( sm->pointer_to_string && *(char **)sm->pointer )
	  {
	     *(char **)sm->pointer = strdup(  *(char **)sm->pointer );
	     update_shared_memory( sm->module );
	  }
	
	shared_memory_table = shared_memory_table->next;
	
	free( sm->name );
	free( sm );
     }
   
   last_sm = shared_memory_table;
   
   if ( !last_sm )
     return;
   
   for ( sm = last_sm->next; sm; last_sm = sm, sm = sm_next )
     {
	sm_next = sm->next;
	if ( sm->module == module )
	  {
	     last_sm->next = sm_next;
	     
	     if ( sm->pointer_to_string && *(char **)sm->pointer )
	       {
		  *(char **)sm->pointer = strdup( *(char **)sm->pointer );
		  update_shared_memory( sm->module );
	       }
	     
	     free( sm->name );
	     free( sm );
	  }
     }
}

