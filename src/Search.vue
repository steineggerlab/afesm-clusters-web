<template>
    <v-container grid-list-md fluid px-0 py-0 id="search-container">
        <v-layout wrap>
            <v-flex xs12 pa-0 >
                <v-parallax
                    :height="windowHeight"
                    :src="require('./assets/bg-bg.png')"
                    dark
                >
                    <v-row
                        align="center"
                        justify="center"
                        class="marv-bg-fg"
                    >
                        <v-col
                            class="text-center"
                            cols="12"
                        >
                            <h1 class="text-h4 font-weight-thin mb-4">
                                AFESM Clusters
                            </h1>
                            <h4 class="subheading">
                                Investigate the <a href="https://foldseek.com" target="_blank" rel="noopener">Foldseek</a> clustered AFESM (<a href="https://alphafold.ebi.ac.uk" target="_blank" rel="noopener">AlphaFold</a> + <a href="https://esmatlas.com/" target="_blank" rel="noopener">ESMatlas</a>) database
                            </h4>
                            
                            <br>
                             
                            <v-tabs
                                class="search-select"
                                slider-size="1"
                                v-model="tab"
                                centered
                                background-color="transparent"
                                dark
                            >
                                <v-tab>Uniprot, MGnify</v-tab>
                                <v-tab>Biome</v-tab>
                                <!-- <v-tab>Taxonomy</v-tab> -->
                                <!-- <v-tab>Structure</v-tab> -->
                            </v-tabs>
                            <v-tabs-items v-model="tab" style="padding: 0.5em;">
                                <v-tab-item>
                                    <v-text-field
                                        outlined
                                        label="Accession"
                                        style="max-width: 400px; margin: 0 auto;"
                                        v-model="query"
                                        :append-icon="inSearch ? $MDI.ProgressWrench : $MDI.Magnify"
                                        :disabled="inSearch"
                                        @click:append="search"
                                        @keyup.enter="search"
                                        @change="selectedExample = null"
                                        @keydown="error = null"
                                        :error="error != null"
                                        :error-messages="error ? error : []"
                                        dark
                                        >
                                    </v-text-field>
                                    
                                    <template>
                                        <h2 class="text-h6 mb-2">
                                            Examples
                                        </h2>
                                        <v-chip-group
                                            column
                                            dark
                                            v-model="selectedExample"
                                            style="max-width: 500px; margin: 0 auto; "
                                        >

                                            <v-chip v-for="item in examples" :key="item.id"
                                                outlined v-on:click="query=item.id" >
                                                <b>{{ item.id }}</b> &emsp; {{ item.desc }}
                                            </v-chip>
                                        </v-chip-group>
                                    </template>
                                </v-tab-item>
                                <v-tab-item>
                                    <BiomeAutocomplete
                                        :append-icon="inSearch ? $MDI.ProgressWrench : $MDI.Magnify"
                                        v-model="queryBiome"
                                        :disabled="inSearch"
                                        @click:append="searchBiome"
                                        @keyup.enter="searchBiome"
                                        @change="selectedExample = null"
                                        @keydown="error = null"
                                        :error="error != null"
                                        :error-messages="error ? error : []"
                                        ></BiomeAutocomplete>

                                    <v-radio-group 
                                        style="
                                            max-width: 400px;
                                            margin: 0 auto;
                                            "
                                        v-model="biomeSearchType"
                                        inline>
                                        <v-radio name="biomeSearchType" label="Include lower Biome lineage" value="lower" dark></v-radio>
                                        <v-radio name="biomeSearchType" label="Exact Biome" value="exact" dark ></v-radio>
                                    </v-radio-group>
                                </v-tab-item>
                                <v-tab-item>
                                    <TaxonomyNcbiSearch
                                        :append-icon="inSearch ? $MDI.ProgressWrench : $MDI.Magnify"
                                        @click:append="searchLCA"
                                        @input="searchLCA"
                                        @keyup.enter="searchLCA"
                                        v-model="queryLCA"
                                        :value="queryLCA ? queryLCA.text : ''"
                                    ></TaxonomyNcbiSearch>
                                    
                                    <v-radio-group 
                                        style="
                                            max-width: 400px;
                                            margin: 0 auto;
                                            "
                                        v-model="lcaSearchType"
                                        inline>
                                        <v-radio name="lcaSearchType" label="Include lower LCA lineage" value="lower" dark></v-radio>
                                        <v-radio name="lcaSearchType" label="Exact LCA identifier" value="exact" dark ></v-radio>
                                    </v-radio-group>
                                </v-tab-item>
                                <!-- <v-tab-item>
                                    <FoldseekSearchButton @response="searchFoldseek($event)" dark></FoldseekSearchButton>
                                </v-tab-item> -->
                            </v-tabs-items>
                        </v-col>
                    </v-row>
                </v-parallax>
            </v-flex>
            <BiomeSearchResult v-if="tab == 1" @total="small = $event > 0; inSearch = false;"></BiomeSearchResult>
            <!-- <GoSearchResult v-if="tab == 1" @total="small = $event > 0; inSearch = false;"></GoSearchResult> -->
            <!-- <LCASearchResult v-else-if="tab == 2" @total="small = $event > 0; inSearch = false;"></LCASearchResult> -->
            <FoldseekSearchResult v-else-if="tab == 3" @total="small = $event > 0; inSearch = false;"></FoldseekSearchResult>
            <v-flex>
                <v-card rounded="0">
                    <v-flex>
                    <v-card-title primary-title class="pb-0 mb-0">
                        <div class="text-h5 mb-0">Reference</div>
                    </v-card-title>
                    <v-card-title primary-title class="pt-0 mt-0">
                        
                        <p class="text-subtitle-1 mb-0" style="word-break: break-word;">
                            Yeo&nbsp;J, Han&nbsp;Y, Bordin&nbsp;N, Lau&nbsp;AM, Kandathil&nbsp;SM, Kim&nbsp;H, Karin&nbsp;EL, Mirdita&nbsp;M, Jones&nbsp;DT, Orengo&nbsp;C, Steinegger&nbsp;M. 
<a href="https://www.biorxiv.org/content/10.1101/2025.04.23.650224v1" target="_blank" rel="noopener">
Metagenomic-scale analysis of the predicted protein structure universe.</a> 
bioRxiv,&nbsp;2025.
                        </p>
                    </v-card-title>
                    </v-flex>
                </v-card>

                <!-- <p class="text-subtitle-1 mb-0 collab">
                    AFESM Clusters is a collaboration between
                    <a href="https://en.snu.ac.kr/">Seoul National University</a>, the
                    <a href="https://www.ebi.ac.uk/">European Bioinformatics Institute</a>, <br>and the
                    <a href="https://www.sib.swiss/">Swiss Institute of Bioinformatics</a>.
                </p> -->
                <!-- <div style="text-align: center; padding-top: 12px; padding-bottom: 40px;">
                    <a style="margin: 12px" rel="external noopener" target="_blank" href="https://en.snu.ac.kr/" height="128">
                        <img class="logos" src="./assets/snu_logo_opt.svg" height="64"/>
                    </a>
                    <a style="margin: 12px" rel="external noopener" target="_blank" href="https://www.ebi.ac.uk/" height="128">
                        <img class="logos" src="./assets/embl_logo.svg" height="64"/>
                    </a>
                    <a style="margin: 12px" rel="external noopener" target="_blank" href="https://www.sib.swiss/" height="128">
                        <img class="logos" src="./assets/logo_sib.svg" height="64"/>
                    </a>
                </div> -->
            </v-flex>
        </v-layout>
    </v-container>
</template>

<script>
import Panel from "./Panel.vue";
import GoAutocomplete from "./GoAutocomplete.vue";
import GoSearchResult from "./GoSearchResult.vue";
import BiomeAutocomplete from "./BiomeAutocomplete.vue";
import BiomeSearchResult from "./BiomeSearchResult.vue";
import FoldseekSearchButton from "./FoldseekSearchButton.vue";
import TaxonomyNcbiSearch from "./TaxonomyNcbiSearch.vue";
import LCASearchResult from "./LCASearchResult.vue";
import FoldseekSearchResult from "./FoldseekSearchResult.vue";

export default {
    name: "search",
    components: { 
        Panel,
        GoAutocomplete,
        GoSearchResult,
        BiomeAutocomplete,
        BiomeSearchResult,
        TaxonomyNcbiSearch,
        LCASearchResult,
        FoldseekSearchButton,
        FoldseekSearchResult,
    },
    data() {
        return {
            tab: 0,
            query: "MGYP006274345917",
            selectedExample: 1,
            examples: [
                {id:'MGYP001309520873', desc:'putative Virus specific protein'},
                {id:'MGYP006274345917', desc:'Phage integrase (Hypersaline)'},
                {id:'MGYP002252011424', desc:'Novel domain'},
                {id:'MGYP001263772116', desc:'Novel Multidomain protein with TonB'},
                // {id:'A0A1S3QU81', desc:' Gasdermin containing domain'},
            ],
            queryBiome: { text: "root:Environmental:Aquatic:Thermal springs", value: "198" },
            goSearchType: "lower",
            biomeSearchType: "exact",
            queryLCA: { text: "Homo sapiens", value: "9606", common_name: "human" },
            lcaSearchType: "lower",
            inSearch: false,
            response: null,
            small: false,
            error: null,
        };
    },
    computed: {
        windowHeight() {
            if (this.small && !this.tab == 0) {
                return 500;
            }
            return Math.max(Math.min(860, (window.innerHeight - 48) * 0.8), 500);
        },
    },
    mounted() {
        this.setTab();
    },
    watch : {
        '$route': function(to, from) {
            if (from.path != to.path) {
                this.setTab();
            }
        }
    },
    methods: {
        log(value) {
            console.log(value);
        },
        setTab() {
            if (this.$route.params.biome) {
                this.tab = 1;
                this.queryBiome = { text: "" + this.$route.params.biome.text, value: this.$route.params.biome.value};
                this.biomeSearchType = this.$route.params.type;
            } else if (this.$route.params.taxid) {
                this.tab = 2;
                this.queryLCA = {text: "" + this.$route.params.taxid, value: this.$route.params.taxid};
                this.lcaSearchType = this.$route.params.type;
            } else if (this.$route.params.jobid) {
                this.tab = 3;
            } else {
                this.tab = 0;
            }
        },
        search() {
            this.inSearch = true;
            this.error = null;
            this.$axios.get("/" + this.query)
                .then(response => {
                    this.$router.push({ name: 'cluster', params: { cluster: response.data[0].rep_accession } })
                })
                .catch((err) => {
                    if (err.response && err.response.data && err.response.data.error) {
                        this.error = err.response.data.error;
                    } else {
                        this.error = "Unknown error";
                    }
                })
                .finally(() => {
                    this.inSearch = false;
                });
        },
        searchGo() {
            if (!this.queryGo) {
                return;
            }
            this.inSearch = true;
            this.error = null;
            this.$router.push({
                name: "go",
                params: { go: this.queryGo.value, type: this.goSearchType }
            })
            .catch((error) => {
                if (error && error.name == "NavigationDuplicated") {
                    this.inSearch = false;
                }
            });
        },
        searchBiome() {
            if (!this.queryBiome) {
                return;
            }
            this.inSearch = true;
            this.error = null;
            this.$router.push({
                name: "biome",
                params: { biome: this.queryBiome.value, type: this.biomeSearchType }
            })
            .catch((error) => {
                if (error && error.name == "NavigationDuplicated") {
                    this.inSearch = false;
                }
            });
        },
        searchLCA() {
            if (!this.queryLCA) {
                return;
            }
            this.inSearch = true;
            this.error = null;
            this.$router.push({
                name: "lca",
                params: { taxid: this.queryLCA.value, type: this.lcaSearchType }
            })
            .catch((error) => {
                if (error && error.name == "NavigationDuplicated") {
                    this.inSearch = false;
                }
            });
        },
        searchFoldseek(jobid) {
            this.inSearch = true;
            this.error = null;
            this.$router.push({
                name: "foldseek",
                params: { jobid: jobid }
            })
            .catch((error) => {
                if (error && error.name == "NavigationDuplicated") {
                    this.inSearch = false;
                }
            });
        }
    }
};
</script>

<style scoped>
#search-container {
    padding:0px;
}
.search-component >>> .v-input--checkbox {
    margin-top: 0px;
}

.search-component >>> .input-group label {
    font-size: 16px;
}

.search-component >>> .v-text-field {
    margin-top: 0px;
    padding-top: 0px;
    margin-bottom: 8px;
}

code {
    font-size: 0.8em;
}

.theme--dark .v-input label {
    color: #FFFFFFB3;
}

.theme--light .v-input label {
    color: #00000099;
}

#search-container >>> .v-slide-group__content {
    justify-content: center;
}

.search-select >>> .v-tabs-bar {
    height: 36px;
}

.search-select >>> .v-tab {
    text-transform: none;
    padding: 0 24px
}
.v-tabs-items {
    background-color: transparent !important;
}

.v-parallax {
    transition: height 0.25s;
}

.marv-bg-fg {
    background: url('./assets/bg-fg.png');
    background-size: 100% auto;
    background-repeat: no-repeat;
    background-attachment: fixed;
    background-position: center center;
}

.logos {
    padding: 4px;
    filter: grayscale(100%);
}

.collab {
    text-align: center;
    padding-top: 40px;
    font-weight: lighter;
    line-height: 1.2;
}

.collab a { 
    text-decoration: none;
    font-weight: 400;
    color: #999;
}

@media (prefers-color-scheme: dark) {
    .logos {
        /* padding: 8px; */
        /* filter: brightness(0) invert(1); */
        filter: grayscale(100%) invert();
        /* background-color: #ddd; */
        /* border-radius: 4px; */
    }

    .collab {
        color: #999;
    }
}

</style>
