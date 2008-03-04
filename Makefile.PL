use inc::Module::Install;
name 'RPC-XML-Parser-LibXML';
all_from 'lib/RPC/XML/Parser/LibXML.pm';

requires 'XML::LibXML';
requires 'RPC::XML';
requires 'Carp';
requires 'Encode';
requires 'MIME::Base64';

build_requires 'Test::More';
build_requires 'YAML';
use_test_base;
auto_include;
WriteAll;
