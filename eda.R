# Count finishes by podium spot
finishes <- merge(all.game.info, game.results, by="j.archive.id")[num.champs == 1, list(left=table(left.rank), center=table(center.rank), right=table(right.rank))]
finishes <- apply(finishes, 2, function(x) x / sum(finishes$left))