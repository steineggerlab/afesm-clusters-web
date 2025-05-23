<template>
	<div class="d-flex flex-column">
		<svg class="hide" ref="svg" width="100%"></svg>
	</div>
</template>

<script>
import * as d3sankey from "d3-sankey";
import { select, selectAll, scaleOrdinal } from "d3";

export default {
	name: "Sankey",
	props: ["cluster", "type"],
	data: () => ({
		response: null,
		sankeyRankOrder: ["superkingdom", "kingdom", "phylum", "family", "genus", "species", "no rank"],
		fullRankOrder: [
			"superkingdom",
			"kingdom",
			"subkingdom",
			"superphylum",
			"phylum",
			"subphylum",
			"superclass",
			"class",
			"subclass",
			"superorder",
			"order",
			"suborder",
			"infraorder",
			"parvorder",
			"superfamily",
			"family",
			"subfamily",
			"supergenus",
			"genus",
			"subgenus",
			"superspecies",
			"species",
			"subspecies",
			"no rank",
			"clade",
		],
		colors: [
			"#57291F",
			"#C0413B",
			"#D77B5F",
			"#FF9200",
			"#FFCD73",
			"#F7E5BF",
			"#C87505",
			"#F18E3F",
			"#E59579",
			"#C14C32",
			"#80003A",
			"#506432",
			"#FFC500",
			"#B30019",
			"#EC410B",
			"#E63400",
			"#8CB5B5",
			"#6C3400",
			"#FFA400",
			"#41222A",
			"#FFB27B",
			"#FFCD87",
			"#BC7576",
		],
	}),
	watch: {
		cluster() {
			this.fetchData();
		},
		response() {
			this.newRender(this.response);
		},
	},
	mounted() {
		this.fetchData();
	},
	methods: {
		fetchData() {
			this.$axios
				.get("/cluster/" + this.cluster + "/sankey-" + this.type)
				.then((response) => {
					this.response = response.data.result;
					// console.log(this.response)
				})
				.catch(() => {});
		},

		// Helper functions for drawing Sankey
		formatCladeReads(value) {
			if (value >= 1000) {
				return `${(value / 1000).toFixed(2)}k`;
			}
			return value.toString();
		},
		formatProportion(value) {
			return `${value.toFixed(3)}%`;
		},

		// Function to store lineage data for each node
		storeLineage(nodes, links) {
			// Create a map for quick access to nodes by their id
			const nodeMap = new Map();

			// Initialize the nodeMap with nodes, each having an empty lineage array
			nodes.forEach((node) => {
				nodeMap.set(node.id, { ...node, lineage: [], children: [] });
			});

			// Process each link to build lineage
			links.forEach((link) => {
				const parentNode = nodeMap.get(link.source);
				const childNode = nodeMap.get(link.target);

				if (parentNode && childNode) {
					// Add the child node to the parent's children array
					parentNode.children.push(childNode);
				}
			});

			// Helper function to propagate lineage updates to children recursively
			function propagateLineage(node) {
				node.children.forEach((childNode) => {
					// Update the child's lineage with the parent's lineage and the parent itself
					childNode.lineage = [...node.lineage, node];

					// Recursively propagate to the child's children
					propagateLineage(childNode);
				});
			}

			// Start by propagating lineage from the root nodes (nodes with no incoming links)
			nodes.forEach((node) => {
				if (nodeMap.get(node.id).lineage.length === 0) {
					propagateLineage(nodeMap.get(node.id));
				}
			});

			// Return the map of nodes with lineage information
			return nodeMap;
		},

		// Parse data function
		parseData(data, isFullGraph = false) {
			const nodes = [];
			const allNodes = [];
			const links = [];
			const allLinks = [];
			const nodesByRank = {}; // Store nodes by rank for filtering top 10

			// Step 1: Create nodes and save lineage data for ALL NODES (excluding clade ranks)
			// Build the node map with lineage
			const nodeLineages = this.storeLineage(data.nodes, data.links);

			data.nodes.forEach((d) => {
				const targetValue = data.links
					.filter((link) => link.target === d.id) // Find links where d.id is the target
					.map((link) => link.value);

				let node = {
					id: d.id,
					name: d.name,
					rank: d.rank,
					// proportion: parseFloat(d.proportion),
					clade_reads: targetValue.length > 0 ? targetValue[0] : 0,
					lineage: [],
					type: "",
				};

				if (d.rank !== "no rank") {
					// Declare type as 'classified'
					node.type = "classified";

					// Add classified node to its corresponding rank collection
					if (!nodesByRank[d.rank]) {
						nodesByRank[d.rank] = [];
					}
					nodesByRank[d.rank].push(node);

					// Include all ranks for lineage tracking
					node.lineage = [...nodeLineages.get(d.id).lineage, node];
				}
			});

			// Step 2: Filter top 10 nodes by clade_reads for each rank in rankOrder
			// + Add filtered rank nodes & unclassified nodes to sankey diagram
			this.sankeyRankOrder.forEach((rank) => {
				if (nodesByRank[rank]) {
					// Store all nodes
					allNodes.push(...nodesByRank[rank]);

					// Sort nodes by clade_reads in descending order and select the top nodes based on slider value
					const topNodes = nodesByRank[rank].sort((a, b) => b.clade_reads - a.clade_reads).slice(0, isFullGraph ? nodesByRank[rank].length : 10); // Don't apply taxaLimit when parsing fullGraphData
					nodes.push(...topNodes);
				}
			});

			// Step 3: Create links based on filtered nodes' lineage
			nodes.forEach((node) => {
				// Find the previous node in the lineage that is in rankOrder
				const lineage = node.lineage;
				let previousNode = null;

				for (let i = lineage.length - 2; i >= 0; i--) {
					// Start from the second last item
					if (this.sankeyRankOrder.includes(lineage[i].rank) && this.hasId(nodes, lineage[i].id)) {
						previousNode = lineage[i];
						break;
					}
				}

				if (previousNode) {
					links.push({
						source: previousNode.id,
						target: node.id,
						value: node.clade_reads,
					});
				}
			});

			// Store links for all nodes
			allNodes.forEach((node) => {
				// Find the previous node in the lineage that is in rankOrder
				const lineage = node.lineage;
				let previousNode = null;

				for (let i = lineage.length - 2; i >= 0; i--) {
					// Start from the second last item
					if (this.sankeyRankOrder.includes(lineage[i].rank) && allNodes.includes(lineage[i])) {
						previousNode = lineage[i];
						break;
					}
				}

				if (previousNode) {
					allLinks.push({
						source: previousNode.id,
						target: node.id,
						value: node.clade_reads,
					});
				}
			});

			return { nodes, links };
		},

		// Check if nodes array contains an object with the same id as lineage[i]
		hasId(nodes, idToCheck) {
			return nodes.some((node) => node.id === idToCheck);
		},

		// Main function for rendering Sankey
		newRender(items) {
			const { nodes, links } = this.parseData(items);

			// Check if nodes and links are not empty
			if (!nodes.length || !links.length) {
				select(this.$refs.svg).classed("hide", true);
				return;
			}

			const container = this.$refs.svg;
			select(container).selectAll("*").remove().classed("hide", false); // Clear the previous diagram

			const width = 960;
			const height = 360;
			const nodeWidth = 30;
			const nodePadding = 13;
			const marginBottom = 50; // Margin for rank labels
			const marginRight = 70;
			const leftMargin = 10;

			const svg = select(container)
				.attr("viewBox", [0, 0, width, height + marginBottom])
				.classed("hide", false);

			const sankeyGenerator = d3sankey
				.sankey()
				.nodeId((d) => d.id)
				.nodeAlign(d3sankey.sankeyJustify)
				.nodeWidth(nodeWidth)
				.nodePadding(nodePadding)
				.iterations(100)
				.extent([
					[10, 10],
					[width - marginRight, height - 6],
				]);
			const graph = sankeyGenerator({
				nodes: nodes.map((d) => Object.assign({}, d)),
				links: links.map((d) => Object.assign({}, d)),
			});

			const color = scaleOrdinal().range(this.colors);
			const unclassifiedLabelColor = "#696B7E";

			// Manually adjust nodes position to align by rank
			const columnWidth = (width - marginRight) / this.sankeyRankOrder.length;

			const tax_to_ranklayer = {};
			for (const node of graph.nodes) {
				node.posX = this.sankeyRankOrder.indexOf(node.rank) * columnWidth + leftMargin;
				tax_to_ranklayer[node.id] = node.posX;
			}

			graph.nodes.forEach((node) => {
				node.x0 = tax_to_ranklayer[node.id];
				node.x1 = node.x0 + sankeyGenerator.nodeWidth();

				if (node.type === "unclassified") {
					node.color = unclassifiedLabelColor;
				} else {
					node.color = color(node.id); // Assign color to node
				}
			});

			// Re-run the layout to ensure correct vertical positioning
			sankeyGenerator.update(graph);

			// Add rank column labels
			const rankLabels = ["D", "K", "P", "F", "G", "S"];
			svg
				.append("g")
				.selectAll("text")
				.data(this.sankeyRankOrder)
				.enter()
				.append("text")
				.attr("x", (d) => this.sankeyRankOrder.indexOf(d) * columnWidth + leftMargin + sankeyGenerator.nodeWidth() / 2)
				.attr("y", height + marginBottom / 2)
				.attr("dy", "0.35em")
				.attr("text-anchor", "middle")
				.text((rank, index) => rankLabels[index]);

			// Draw rank label divider link
			svg
				.append("line")
				.attr("x1", 0)
				.attr("y1", height + 10)
				.attr("x2", width)
				.attr("y2", height + 10)
				.attr("stroke", "#000")
				.attr("stroke-width", 1);

			// Function to highlight lineage
			const highlightLineage = (node) => {
				const lineageIds = new Set(node.lineage.map((n) => n.id));
				lineageIds.add(node.id);

				svg.selectAll("rect").style("opacity", (d) => (lineageIds.has(d.id) ? 1 : 0.2));
				svg.selectAll("path").style("opacity", (d) => (lineageIds.has(d.source.id) && lineageIds.has(d.target.id) ? 1 : 0.2));
				svg.selectAll(".label").style("opacity", (d) => (lineageIds.has(d.id) ? 1 : 0.1));
				svg.selectAll(".clade-reads").style("opacity", (d) => (lineageIds.has(d.id) ? 1 : 0.1));
			};

			// Function to reset highlight
			const resetHighlight = () => {
				svg.selectAll("rect").style("opacity", 1);
				svg.selectAll("path").style("opacity", 1);
				svg.selectAll(".label").style("opacity", 1);
				svg.selectAll(".clade-reads").style("opacity", 1);
			};

			// Define a clipping path for each link (crops out curve when links are too thick)
			svg
				.append("defs")
				.selectAll("clipPath")
				.data(graph.links)
				.enter()
				.append("clipPath")
				// .attr("id", (d, i) => `clip-path-${this.instanceId}-${i}`)
				.append("rect")
				.attr("x", (d) => d.source.x1)
				.attr("y", 0)
				.attr("width", (d) => d.target.x0 - d.source.x1)
				.attr("height", height);

			// Add links
			svg
				.append("g")
				.attr("fill", "none")
				.attr("stroke-opacity", 0.3)
				.selectAll("path")
				.data(graph.links)
				.enter()
				.append("path")
				.attr("d", d3sankey.sankeyLinkHorizontal())
				.attr("stroke", (d) => (d.target.type === "unclassified" ? unclassifiedLabelColor : color(d.source.color))) // Set link color to source node color with reduced opacity
				.attr("stroke-width", (d) => Math.max(1, d.width));
			// .attr("clip-path", (d, i) => `url(#clip-path-${this.instanceId}-${i})`);

			// Create node group (node + labels) and add mouse events
			const nodeGroup = svg
				.append("g")
				.selectAll(".node-group")
				.data(graph.nodes)
				.enter()
				.append("g")
				.attr("class", (d) => "node-group taxid-" + d.id)
				.attr("transform", (d) => `translate(${d.x0}, ${d.y0})`)
				.on("mouseover", (event, d) => {
					highlightLineage(d);
					// Create the tooltip div
					select("body")
						.append("div")
						.attr("class", "tooltip")
						.html(
							`
							<div style="padding-top: 4px; padding-bottom: 4px; padding-left: 8px; padding-right: 8px;">
								<p style="font-size: 0.6rem; margin-bottom: 0px;">#${d.id}</p>
								<div style="display: flex; justify-content: space-between; align-items: center;">
									<div style="font-weight: bold; font-size: 0.875rem;">${d.name}</div>
									<span style="background-color: rgba(255, 167, 38, 0.25); color: #ffa726; font-weight: bold; padding: 4px 8px; border-radius: 12px; font-size: 0.875rem; margin-left: 10px;">${d.rank}</span>
								</div>
								<hr style="margin: 8px 0; border: none; border-top: 1px solid #fff; opacity: 0.2;">
								<div style="display: flex; justify-content: space-between; align-items: center; font-size: 0.875rem;">
									<div style="font-weight: bold;">Clade Reads</div>
									<div style="margin-left: 10px;">${d.value}</div>
								</div>
							</div>
						`
						)
						.style("left", `${d.x + d.dx}px`)
						.style("top", `${d.y + window.scrollY}px`);
				})
				.on("mousemove", (event, d) => {
					// Move the tooltip as the mouse moves
					select(".tooltip")
						.style("left", `${event.pageX + 10}px`)
						.style("top", `${event.pageY + 10}px`);
				})
				.on("mouseout", () => {
					resetHighlight();
					// Remove the tooltip when mouse leaves
					select(".tooltip").remove();
				})
				.on("click", (event, d) => {
					if (event.target.classList.contains("active")) {
						selectAll("rect.node, text.label").classed("active", false);
						this.$emit("select", null);
					} else {
						selectAll("rect.node, text.label").classed("active", false);
						selectAll(".taxid-" + d.id).classed("active", true);
						this.$emit("select", { name: d.name, id: d.id });
					}
				});

			// Create node rectangles
			nodeGroup
				.append("rect")
				.attr("width", (d) => d.x1 - d.x0)
				.attr("height", (d) => Math.max(1, d.y1 - d.y0))
				.attr("fill", (d) => (d.type === "unclassified" ? unclassifiedLabelColor : d.color))
				.attr("class", (d) => "node taxid-" + d.id) // Apply the CSS class for cursor
				.style("cursor", "pointer");

			// Add node name labels next to node
			nodeGroup
				.append("text")
				.attr("id", (d) => `nodeName-${d.id}`)
				.attr("class", (d) => "label taxid-" + d.id)
				.attr("x", (d) => d.x1 - d.x0 + 3)
				.attr("y", (d) => (d.y1 - d.y0) / 2)
				.attr("dy", "0.35em")
				.attr("text-anchor", "start")
				.text((d) => d.name)
				.style("font-size", "9px")
				.style("cursor", "pointer");

			// Add label above node (proportion/clade reads)
			nodeGroup
				.append("text")
				.attr("id", (d) => `cladeReads-${d.id}`)
				.attr("class", "clade-reads")
				.attr("x", (d) => (d.x1 - d.x0) / 2)
				.attr("y", -4)
				.attr("dy", "0.35em")
				.attr("text-anchor", "middle")
				.style("font-size", "9px")
				.text((d) => this.formatCladeReads(d.value))
				.style("cursor", "pointer");

			// Highlight nodes matching search query
			// this.highlightNodes(this.searchQuery);
		},
	},
};
</script>

<style>
.theme--dark svg text {
	fill: white;
}
.theme--light svg text {
	fill: black;
}

svg.hide {
	display: none;
}

svg text {
	cursor: pointer;
	font-size: calc(30px + (8 - 16) * ((100vw - 320px) / (640 - 320)));
}

svg text.label.active {
	font-weight: bold;
}

svg rect.node {
	cursor: pointer;
}

svg rect.node.active {
	stroke-width: 2px;
	stroke: #333;
}

@media (min-width: 641px) {
	svg text {
		font-size: calc(16px + (4 - 8) * ((100vw - 640px) / (1280 - 640)));
	}
}

@media (min-width: 1280px) {
	svg text {
		font-size: 10px;
	}
}

/* Node Hover Tooltip */
.tooltip {
	position: absolute;
	background-color: rgba(38, 50, 56, 0.95);
	padding: 10px;
	border-radius: 8px;
	color: white;
	pointer-events: none;
	z-index: 10;
}
</style>
