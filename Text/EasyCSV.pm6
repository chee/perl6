unit class Text::EasyCSV;
use Text::CSV;
my $csv = Text::CSV.new;

sub load-csv ($path) is export {
	my $io  = open(
		$path,
		:r,
		chomp => False
	);
	my @data = $csv.getline_all($io);
	return @data;
}
