import { idx_to_rank } from './ncbitaxonomy.mjs';

function makeSankey(result, tree) {
    let nodes = {};
    let links = {};
    const allowedRanks = [28, 27, 24, 12, 8, 4];
    result.forEach((x) => {
        if (tree.nodeExists(x.tax_id) == false) {
            return;
        }
        let node = tree.getNode(x.tax_id, true);
        while (node.id != 1) {
            let currentNode = node;
            // skip all ranks except superkingdom, phylum, class, order, family, genus
            while (!allowedRanks.includes(currentNode.rank)) {
                currentNode = tree.getNode(currentNode.parent, true);
                if (currentNode.id == 1) {
                    break;
                }
            }

            let parentNode = tree.getNode(currentNode.parent, true);
            while (!allowedRanks.includes(parentNode.rank)) {
                parentNode = tree.getNode(parentNode.parent, true);
                if (parentNode.id == 1) {
                    break;
                }
            }

            if (!(currentNode.id in nodes)) {
                nodes[currentNode.id] = {
                    id: currentNode.id,
                    name: currentNode.name,
                    rank: idx_to_rank[currentNode.rank],
                };
            }

            if (!(parentNode.id in nodes)) {
                nodes[parentNode.id] = {
                    id: parentNode.id,
                    name: parentNode.name,
                    rank: idx_to_rank[parentNode.rank],
                };
            }

            node = parentNode;
            if (currentNode.id == 1 || parentNode.id == 1) {
                break;
            }

            const linkKey = `${currentNode.id}-${parentNode.id}`;
            if (!(linkKey in links)) {
                links[linkKey] = {
                    source: parentNode.id,
                    target: currentNode.id,
                    value: 1,
                    rank: idx_to_rank[parentNode.rank],
                    name: parentNode.name,
                }
            } else {
                links[linkKey].value += 1;
            }
        }
    });
    // nodes['root'] = { id : 'root' };
    return { nodes : Object.values(nodes), links : Object.values(links) };
}

function makeBiomeSankey(result, tree, biomeMap, biomeMap_strToId) {
    let nodes = {};
    let links = {};
    const allowedRanks = [28, 27, 24, 12, 8, 4];
    const levelToRank = {
      1: "superkingdom", 
      2: "kingdom", 
      3: "phylum",
      4: "family",
      5: "genus",
      6: "species"
    }

    result.forEach((x) => {
        if (x.biome_id == 0) {
          return;
        }
        let biome = biomeMap[x.biome_id];
        let tokens = biome.split(':');

        for (let i = tokens.length; i >= 1; i--) {
            const currentName = tokens.slice(0, i).join(':');
            // console.log(currentName)
            const parentName = tokens.slice(0, i-1).join(':');

            let currentNodeId = biomeMap_strToId[currentName]
            let parentNodeId = (i != 1) ? biomeMap_strToId[parentName] : 0;

            if (!(currentNodeId in nodes)) {
                nodes[currentNodeId] = {
                    id: currentNodeId,
                    name: tokens[i-1],
                    rank: levelToRank[i],
                };
            }

            if (!(parentNodeId in nodes)) {
                nodes[parentNodeId] = {
                    id: parentNodeId,
                    name: (i != 1) ? tokens[i-2] : 'None',
                    rank: levelToRank[i-1],
                };
            }

            const linkKey = `${currentNodeId}-${parentNodeId}`;
            if (!(linkKey in links)) {
                links[linkKey] = {
                    source: parentNodeId,
                    target: currentNodeId,
                    value: 1,
                    rank: levelToRank[i],
                    name: (i != 1) ? tokens[i-2] : 'None',
                }
            } else {
                links[linkKey].value += 1;
            }
        }
    });

    return { nodes : Object.values(nodes), links : Object.values(links) };
}

export { makeSankey, makeBiomeSankey };