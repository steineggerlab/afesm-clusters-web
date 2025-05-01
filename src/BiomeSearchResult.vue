<template>
<v-flex xs12>
<panel class="query-panel d-flex fill-height" fill-height>
    <template slot="header">
        Cluster selection
    </template>

    <template slot="content">
        <v-data-table
            :headers="headers"
            :items="response"
            :options.sync="options"
            :server-items-length="total"
            :footer-props="{
                'items-per-page-options': [10, 20, 50, 100, -1],
            }"
        >
            <template v-slot:item.structure="prop">
                <div style="text-align: center;">
                    <router-link :to="{ name: 'cluster', params: { cluster: prop.item.rep_accession }}" target='_blank'>
                        <img :src="getImage(prop.item.rep_accession)" style="height:75px"/>
                    </router-link>
                </div>
            </template>

            <template v-slot:item.rep_accession="prop">
                <ExternalLinks :accession="prop.value">
                    <router-link slot="accession" :to="{ name: 'cluster', params: { cluster: prop.value }}" target='_blank'>{{ prop.value }}</router-link>
                </ExternalLinks><br>
                {{ prop.item.description  }}
            </template>

            <template v-slot:item.avg_plddt="prop">
                {{ prop.value.toFixed(2) }}
            </template>


            <template v-slot:item.avg_all_plddt="prop">
                {{ prop.value.toFixed(2) }}
            </template>


            <template v-slot:item.avg_all_len="prop">
                {{ prop.value.toFixed(2) }}
            </template>

            <!-- <template v-slot:item.n_all_mem="prop">
                {{ prop.value.toFixed(2) }}
            </template> -->

            <template v-slot:item.rep_plddt="prop">
                {{ prop.value.toFixed(2) }}
            </template>

            <template v-slot:header.lca_tax_id="{ header }">
                <TaxonomyAutocomplete
                    v-model="options.tax_id"
                    :urlFunction="(_, b) => '/search/biome/' + b"
                    :disabled="taxAutocompleteDisabled"
                    :options="requestOptions"
                ></TaxonomyAutocomplete>
            </template>

            <template v-slot:item.lca_tax_id="prop">
                <TaxSpan :taxonomy="prop.value"></TaxSpan>
            </template>

            <template v-slot:item.biome_lineage="prop">
                <!-- <TaxSpan :taxonomy="prop.value"></TaxSpan> -->
                {{ prop.item.biome_lineage  }}
            </template>

            <template v-slot:header.is_only_esm="{ header }">
                <v-menu
                    :close-on-content-click="false"
                    offset-y>
                    <template v-slot:activator="{ on }">
                        <v-btn v-on="on" :outlined="options.is_only_esm != null" plain>
                            {{ header.text }}
                        </v-btn>
                    </template>

                    <v-card style="padding: 2em; width: 250px;">
                        <h3>Filter by</h3>
                        <v-chip-group column v-model="options.is_only_esm">
                            <IsESMOnly isESMOnly="0"></IsESMOnly>
                            <IsESMOnly isESMOnly="1"></IsESMOnly>
                        </v-chip-group>
                    </v-card>
                </v-menu>
            </template>

            <template v-slot:item.is_only_esm="prop">
                <IsESMOnly :isESMOnly="prop.value"></IsESMOnly>
            </template>

            <template v-slot:header.avg_all_len="{ header }">
                <v-menu
                    :close-on-content-click="false"
                    offset-y>
                    <template v-slot:activator="{ on }">
                        <v-btn v-on="on" plain>
                            {{ header.text }}
                        </v-btn>
                    </template>
                    <RangeSlider :range="options.avg_all_length_range"></RangeSlider>
                </v-menu>
            </template>

            <template v-slot:header.avg_all_plddt="{ header }">
                <v-menu
                    :close-on-content-click="false"
                    offset-y>
                    <template v-slot:activator="{ on }">
                        <v-btn v-on="on" plain>
                            {{ header.text }}
                        </v-btn>
                    </template>
                    <RangeSlider :range="options.avg_all_plddt_range"></RangeSlider>
                </v-menu>
            </template>

            <template v-slot:header.n_all_mem="{ header }">
                <v-menu
                    :close-on-content-click="false"
                    offset-y>
                    <template v-slot:activator="{ on }">
                        <v-btn v-on="on" plain>
                            {{ header.text }}
                        </v-btn>
                    </template>
                    <RangeSlider :range="options.n_all_mem_range"></RangeSlider>
                </v-menu>
            </template>

            <template v-slot:header.avg_len="{ header }">
                <v-menu
                    :close-on-content-click="false"
                    offset-y>
                    <template v-slot:activator="{ on }">
                        <v-btn v-on="on" plain>
                            {{ header.text }}
                        </v-btn>
                    </template>
                    <RangeSlider :range="options.avg_length_range"></RangeSlider>
                </v-menu>
            </template>

            <template v-slot:header.avg_plddt="{ header }">
                <v-menu
                    :close-on-content-click="false"
                    offset-y>
                    <template v-slot:activator="{ on }">
                        <v-btn v-on="on" plain>
                            {{ header.text }}
                        </v-btn>
                    </template>
                    <RangeSlider :range="options.avg_plddt_range"></RangeSlider>
                </v-menu>
            </template>

            <template v-slot:header.n_mem="{ header }">
                <v-menu
                    :close-on-content-click="false"
                    offset-y>
                    <template v-slot:activator="{ on }">
                        <v-btn v-on="on" plain>
                            {{ header.text }}
                        </v-btn>
                    </template>
                    <RangeSlider :range="options.n_mem_range"></RangeSlider>
                </v-menu>
            </template>

            <template v-slot:header.rep_len="{ header }">
                <v-menu
                    :close-on-content-click="false"
                    offset-y>
                    <template v-slot:activator="{ on }">
                        <v-btn v-on="on" plain>
                            {{ header.text }}
                        </v-btn>
                    </template>
                    <RangeSlider :range="options.rep_length_range"></RangeSlider>
                </v-menu>
            </template>

            <template v-slot:header.rep_plddt="{ header }">
                <v-menu
                    :close-on-content-click="false"
                    offset-y>
                    <template v-slot:activator="{ on }">
                        <v-btn v-on="on" plain>
                            {{ header.text }}
                        </v-btn>
                    </template>
                    <RangeSlider :range="options.rep_plddt_range"></RangeSlider>
                </v-menu>
            </template>

        </v-data-table>
    </template>
</panel>
</v-flex>
</template>

<script>
import Panel from "./Panel.vue";
import TaxSpan from "./TaxSpan.vue";
import TaxonomyAutocomplete from "./TaxonomyAutocomplete.vue";
// import IsESMOnly from './IsESMOnly.vue';
import RangeSlider from './RangeSlider.vue';
import ExternalLinks from "./ExternalLinks.vue";
import ImageMixin from "./ImageMixin";
import IsESMOnly from "./IsESMOnly.vue";

export default {
    name: "gosearchresult",
    components: { 
        Panel,
        TaxSpan,
        TaxonomyAutocomplete,
        IsESMOnly,
        RangeSlider,
        ExternalLinks
    },
    mixins: [ImageMixin],
    data() {
        return {
            response: [],
            total: null,
            page: null,
            headers: [
                {
                    text: "Structure",
                    value: "structure",
                    sortable: false,
                    width: "10%",
                },
                {
                    text: "Accession",
                    value: "rep_accession",
                    sortable: false,
                },
                // {
                //     text: "LCA rank",
                //     value: "lca_tax_id.rank"
                // },
                {
                    text: "LCA",
                    value: "lca_tax_id",
                    sortable: false,
                },
                {
                    text: "LCB",
                    value: "biome_lineage",
                    sortable: false,
                },
                {
                    text: "Avg. length (ALL)",
                    value: "avg_all_len",
                    sortable: false,
                },
                {
                    text: "Avg. pLDDT (ALL)",
                    value: "avg_all_plddt",
                    sortable: false,
                },
                {
                    text: "All Members",
                    value: "n_all_mem",
                    sortable: false,
                },
                {
                    text: "Avg. length",
                    value: "avg_len",
                    sortable: false,
                },
                {
                    text: "Avg. pLDDT",
                    value: "avg_plddt",
                    sortable: false,
                },
                {
                    text: "Members",
                    value: "n_mem",
                    sortable: false,
                },
                {
                    text: "ESMonly",
                    value: "is_only_esm",
                    sortable: false,
                },
                {
                    text: "Rep. pLDDT",
                    value: "rep_plddt",
                    sortable: false,
                },
                {
                    text: "Rep. length",
                    value: "rep_len",
                    sortable: false,
                },
            ],
            options: {
                avg_length_range: [0, Infinity],
                avg_plddt_range: [0, Infinity],
                avg_all_length_range: [0, Infinity],
                avg_all_plddt_range: [0, Infinity],
                rep_length_range: [0, Infinity],
                rep_plddt_range: [0, Infinity],
                n_mem_range: [0, Infinity],
                n_all_mem_range: [0, Infinity],
                tax_id: null,
                is_only_esm: null,
                // is_dark: null,
            },
            taxAutocompleteDisabled: false,
            range: [5, 5],
        };
    },
    mounted() {
        this.fetchData();
    },
    watch : {
        options: {
            handler () {
                this.fetchData()
            },
            deep: true,
        },
        '$route': function(to, from) {
            if (from.path != to.path) {
                this.fetchData();
            }
        }
    },
    computed: {
        requestOptions() {
            // console.log('hiz')
            const options = {
                "query_Biome": this.$route.params.biome,
                "biome_search_type": this.$route.params.type,
                "search_type": "biome",
            };
            // console.log(options)
            const obj = Object.assign({}, this.options, options);
            let copy = JSON.parse(JSON.stringify(obj));
            if (copy.tax_id) {
                copy.tax_id = copy.tax_id.value;
            } else {
                delete copy.tax_id;
            }
            if (copy.is_dark == null) {
                delete copy.is_dark;
            }
            if (copy.is_only_esm == null) {
                delete copy.is_only_esm;
            }
            const params = new URLSearchParams(copy);
            params.sort();
            return { params };
        },
    },
    methods: {
        log(value) {
            console.log(value);
        },
        fetchData () {
            // console.log("zz", this.$route.params)
            if (!this.$route.params.biome) {
                return;
            }
            if (!this.$route.params.type) {
                return;
            }
            
            // console.log("called", this.requestOptions)
            this.loading = true;
            this.$axios.get("/search/biome", this.requestOptions)
                .then(response => {
                    console.log('biomes', this.response)
                    this.response = response.data.result;
                    // console.log(this.response)
                    this.total = response.data.total;
                    this.fetchImages(this.response.map(m => m.rep_accession));
                    this.$emit('total', this.total);
                })
                .finally(() => {
                    this.loading = false;
                });
        }
    }
};
</script>
