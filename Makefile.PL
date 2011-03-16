use inc::Module::Install;

name "earthquake-growler";
all_from "earthquake-growler.pl";
install_script "earthquake-growler.pl";

requires 'XML::Feed';
requires 'XML::Feed::Deduper';
requires 'Growl::Any';
requires 'File::Spec';

WriteAll;
