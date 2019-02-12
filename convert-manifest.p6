#!/usr/bin/env perl6
use JSON::Tiny;
my $components = from-json(slurp "components.json");
my $mappings = from-json(slurp "components.json");

sub add-npm-org (Str $name) {
	return qq｢@financial-times/{$name}｣;
}

sub create-npm-dependency (Str $name, Str $version) {
	my $is-origami-component = $components.contains($name);

	my $name-is-mapped = $mappings<name>.keys.contains($name);
	my $version-is-mapped = $mappings<version>.keys.contains($version);

	if ($is-origami-component) {
		return $name, $version;
	}

	if ($name-is-mapped) {
		return $mappings<name><<$name>>, $version;
	}

	if ($version-is-mapped) {
		return $name, $mappings<version><<$version>>;
	}

	return $name, $version;
}

sub MAIN (Str $version where * ~~ /^\d+\.\d+\.\d+$/) {
	my $bowerManifest = from-json(lines);
	my $packageManifest = {};
	$packageManifest<version> = $version;
	my (
		$name,
		$description,
		$homepage,
		$license,
		$dependencies
	) = $bowerManifest;

	$packageManifest<name> = add-npm-org($name);
	$packageManifest<description> = $description;
	$packageManifest<homepage> = $homepage;
	$packageManifest<dependencies> = $dependencies.hyper.map(&create-npm-dependency);

	put to-json($packageManifest);
}
