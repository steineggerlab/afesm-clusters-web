<template>
    <v-tooltip open-delay="300" top>
        <template v-slot:activator="{ on }">
            <v-autocomplete
                outlined
                :value="value"
                label="LCB (Lowest common biome)"
                placeholder="Start typing MGnify biome"
                hide-no-data
                :items="items"
                :loading="isLoading"
                :search-input.sync="search"
                style="max-width: 400px; margin: 0 auto;"
                @input="change"
                return-object
                auto-select-first
                :allow-overflow="false"
                dark
                v-bind="$attrs"
                v-on="$listeners"
            >
                <template v-slot:item="{ item }">
                    {{ item.text }}<template v-if="item.common_name">&nbsp;({{ item.common_name }})</template>
                </template>
            </v-autocomplete>
        </template>
        <span>Restrict results to taxonomic clade</span>
    </v-tooltip>
</template>

<script>
import { create } from 'axios';
import { debounce } from './lib/debounce';

export default {
  props: ['value'],
  data() {
      return {
          items: [],
          isLoading: false,
          search: null,
      }
  },
  mounted() {
      this.items = [ this.value ];
  },
  watch: {
      value(val) {
          this.items = [ this.value ];
      },
      search (val) {
          val && val.length > 2 && val !== this.value && this.querySelections(val)
      },
  },
  methods: {
      change(taxId) {
        // console.log(taxId)
        this.$emit('input', taxId);
      },
      querySelections: debounce(function (name) {
          this.loading = true;
        //   console.log('BiomeSearch.vue clicked', this.value, name);
        //   // make a new axios instance to not leak the electron access token
          const axios = create();
            this.$axios.get("/autocomplete/biome/" + encodeURIComponent(name))
                .then(response => {
                    if (response.status == 200 && response.data.hasOwnProperty("result")) {
                        this.items = response.data.result.map((el) => {
                            return { text: el.biome_name, value: el.biome_id }
                        });
                    }
                }).finally(() => { this.isLoading = false; });
      }, 500, false)
  },
}
</script>

<style>
</style>