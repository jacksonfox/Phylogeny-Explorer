# Example Collection (Primates)

This is an example collection for the Phylogeny Explorer web application. Each collection is placed in a sub-directory under the `data` directory. If you add a new collection, the web application needs to be restarted to load the new collection data.

- `data/`
 	- `primates/`
		- `config.yml` - simple config file
 		- `preview.jpg` - image shown on the homepage
 		- `primates.csv` - description of species in the collection in CSV format
		- `primates_dist.csv` - genetic distance data in CSV format
 		- `images/` - directory containing species images

The main configuration file is `config.yml`, which specifies the name of the collection, the filename of a preview image for the homepage, and which files contain the species information and genetic distance data.

The species data file is in CSV format:

`ID, species_name, domain, image_file, wikipedia_url, animal_diversity_url`

The distance data is also in CSV format:

`species_name1, species_name2, distance`

**Note:** Make sure that species names are consistent across files. 