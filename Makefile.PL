use inc::Module::Install;
name 'RPC-XML-Parser-LibXML';
all_from 'lib/RPC/XML/Parser/LibXML.pm';

requires 'XML::LibXML' => '1.73';
requires 'RPC::XML' => 0.73;
requires 'Carp';
requires 'Encode';
requires 'MIME::Base64';

auto_set_repository();
readme_markdown_from_pod('lib/RPC/XML/Parser/LibXML.pm');

author_tests('xt');
build_requires 'Test::More';
WriteAll;
