import json

# Step 1: Define a rank → number mapping
rank_map = {
    "biotype": 38,
    "clade": 34,
    "class": 21,
    "cohort": 42,
    "family": 12,
    "forma": 1,
    "forma specialis": 29,
    "genotype": 36,
    "genus": 8,
    "infraclass": 19,
    "infraorder": 15,
    "isolate": 33,
    "kingdom": 27,
    "morph": 37,
    "no rank": 0,
    "order": 17,
    "parvorder": 14,
    "pathogroup": 40,
    "phylum": 24,
    "section": 35,
    "series": 43,
    "serogroup": 32,
    "serotype": 31,
    "species": 4,
    "species group": 6,
    "species subgroup": 5,
    "strain": 30,
    "subclass": 20,
    "subcohort": 39,
    "subfamily": 11,
    "subgenus": 7,
    "subkingdom": 26,
    "suborder": 16,
    "subphylum": 23,
    "subsection": 41,
    "subspecies": 3,
    "subtribe": 9,
    "superclass": 22,
    "superfamily": 13,
    "superkingdom": 28,
    "superorder": 18,
    "superphylum": 25,
    "tribe": 10,
    "varietas": 2,
}

# Step 2: Parse names.dmp to get scientific names
def parse_names_dmp(file_path):
    names = {}
    with open(file_path) as f:
        for line in f:
            fields = [x.strip() for x in line.split('|')]
            tax_id, name_txt, _, name_class = fields[:4]
            if name_class == "scientific name":
                names[tax_id] = name_txt
    return names

# Step 3: Parse nodes.dmp and construct final dict
def build_ncbitaxonomy_json(nodes_file, names):
    taxonomy = {}
    with open(nodes_file) as f:
        for line in f:
            fields = [x.strip() for x in line.split('|')]
            tax_id, parent_id, rank = fields[0], fields[1], fields[2]
            rank_id = rank_map.get(rank, 0)
            name = names.get(tax_id, "")
            taxonomy[tax_id] = {
                "i": int(tax_id),
                "p": int(parent_id),
                "r": rank_id,
                "n": name
            }
    return taxonomy

# Main runner
names = parse_names_dmp("afesm_names.dmp")
taxonomy = build_ncbitaxonomy_json("afesm_nodes.dmp", names)

with open("ncbitaxonomy.json", "w") as f:
    json.dump(taxonomy, f, separators=(',', ':'), ensure_ascii=False)