#!/usr/bin/env perl6
use JSON::Pretty;
my $components = from-json(slurp "components.json");
my $mappings = from-json(slurp "components.json");

sub add-npm-org (Str $name) {
	return qq｢@financial-times/{$name}｣;
}

sub create-npm-dependency (Str $name, Str $version) {
	my $is-origami-component = $components.contains($name);

	if ($is-origami-component) {
		return add-npm-org($name), $version;
	}

	my $name-is-mapped = $mappings<name>.keys.contains($name);
	if ($name-is-mapped) {
		return $mappings<name><<$name>>, $version;
	}

	my $version-is-mapped = $mappings<version>.keys.contains($version);
	if ($version-is-mapped) {
		return $name, $mappings<version><<$version>>;
	}

	my $hash-version-match = $version ~~ /'#'(\^?\d+\.\d+\.\d+)/;
	if ($hash-version-match.so) {
		return $name, @$hash-version-match[0].Str;
	}

	return $name, $version;
}

sub MAIN (Str $version where * ~~ /^\d+\.\d+\.\d+$/) {
	my $bowerManifest = from-json(lines);
	my $packageManifest = {};
	$packageManifest<version> = $version;

	$packageManifest<name> = add-npm-org($bowerManifest<name>);
	$packageManifest<description> = $bowerManifest<description>;
	$packageManifest<homepage> = $bowerManifest<homepage>;
	$packageManifest<license> = $bowerManifest<license>;
	$packageManifest<dependencies> = $bowerManifest<dependencies>.map({
		my ($name, $version) = create-npm-dependency(.key, .value);
		Pair.new: $name, $version;
	}).Hash;
	put to-json($packageManifest);
}
