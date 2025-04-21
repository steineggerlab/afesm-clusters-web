<template>
    <span v-if="!taxonomy">
      Unknown
    </span>
    <span v-else-if="taxonomy.id === 0">
      {{ taxonomy.name }}
    </span>
    <a v-else
       :href="'https://www.ncbi.nlm.nih.gov/Taxonomy/Browser/wwwtax.cgi?mode=Info&id=' + taxonomy.id"
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
}
</script>