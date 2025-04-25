<template>
    <span v-if="!taxonomy">
      Unknown
    </span>
    <span v-else-if="taxonomy.id === 0">
      {{ taxonomy.name }}
    </span>
    <a v-else-if="taxonomy.id <= 4000000"
       :href="'https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=' + taxonomy.id"
       :title="'Taxonomic ID: ' + taxonomy.id + ' Rank: ' + taxonomy.rank">
      {{ taxonomy.name }}
    </a>
    <a v-else
       :href="'https://gtdb.ecogenomic.org/searches?s=al&q=' + encodeURIComponent(taxonomy.name)"
       :title="'Taxonomic ID: ' + taxonomy.id + ' Rank: ' + taxonomy.rank">
      {{ taxonomy.name }}
    </a>
  </template>

<script>
export default {
    name: "taxspan",
    props: {
        taxonomy: {
            type: [Object, null],
            default: null,
        },
    },
  // mounted() {
  //   console.log("Taxonomy loaded:", this.taxonomy);
  // }
}
</script>