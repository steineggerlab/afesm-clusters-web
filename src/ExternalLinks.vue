<template>
    <v-menu
        :close-on-content-click="false">
        <template v-slot:activator="{ on }">
            <a
                :href="accession.startsWith('MGYP') 
                ? `https://esmatlas.com/resources/detail/${accession}` 
                : `https://www.uniprot.org/uniprotkb/${accession}`"
                target="_blank"
                rel="noopener noreferrer"
            >
                <slot v-if="$slots['accession']" name="accession"></slot>
                <template v-else>{{ accession }}</template>
            </a>
        </template>
        <!-- <v-list>
            <v-list-item :href="'https://www.uniprot.org/uniprotkb/' + accession" target="_blank" rel="noopener">
                <v-list-item-content>
                    <v-list-item-title>UniProt</v-list-item-title>
                </v-list-item-content>
            </v-list-item>
            <v-list-item :href="'https://uniprot3d.org/atlas/AFDB90v4/#' + accession" target="_blank" rel="noopener">
                <v-list-item-content>
                    <v-list-item-title>UniProt3D Atlas</v-list-item-title>
                </v-list-item-content>
            </v-list-item>
        </v-list> -->
    </v-menu>
</template>

<script>
export default {
    name: "externallinks",
    props: {
        accession: {
            type: String,
            required: true,
        },
    },
};
</script>
