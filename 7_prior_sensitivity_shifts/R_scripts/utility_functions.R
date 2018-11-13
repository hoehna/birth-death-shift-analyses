matchNodes = function(phy) {

  # get some useful info
  num_tips = length(phy$tip.label)
  num_nodes = phy$Nnode
  tip_indexes = 1:num_tips
  node_indexes = num_tips + num_nodes:1

  node_map = data.frame(R=1:(num_tips + num_nodes), Rev=NA, visits=0)
  current_node = phy$Nnode + 2
  k = 1
  t = 1

  while(TRUE) {

    if ( current_node <= num_tips ) {
      node_map$Rev[node_map$R == current_node] = t
      current_node = phy$edge[phy$edge[,2] == current_node,1]
      t = t + 1
    } else {

      if ( node_map$visits[node_map$R == current_node] == 0 ) {
        node_map$Rev[node_map$R == current_node] = node_indexes[k]
        k = k + 1
      }
      node_map$visits[node_map$R == current_node] = node_map$visits[node_map$R == current_node] + 1

      if ( node_map$visits[node_map$R == current_node] == 1 ) {
        # go right
        current_node = phy$edge[phy$edge[,1] == current_node,2][2]
      } else if ( node_map$visits[node_map$R == current_node] == 2 ) {
        # go left
        current_node = phy$edge[phy$edge[,1] == current_node,2][1]
      } else if ( node_map$visits[node_map$R == current_node] == 3 ) {
        # go down
        if (current_node == num_tips + 1) {
          break
        } else {
          current_node = phy$edge[phy$edge[,2] == current_node,1]
        }
      }
    }

  }

  return(node_map[,1:2])

}

addLegend = function(tree, bins, colors, width=0.1, height=0.4, lwd=1, title="posterior probability", ...) {

  lastPP <- get("last_plot.phylo", envir = .PlotPhyloEnv)

  x_left   = width
  x_right  = width + width * lastPP$x.lim[2]
  y_bottom = bins[-length(bins)] * height * length(tree$tip.label)
  y_top    = bins[-1] * height * length(tree$tip.label)

  ticks = pretty(bins)
  ticks = ticks[ticks > min(bins)]
  ticks = ticks[ticks < max(bins)]
  y_tick = ticks * height * length(tree$tip.label)
  if(lwd > 0) {
    segments(x0=x_right, x1=x_right + 0.01 * abs(diff(lastPP$x.lim)), y0=y_tick, lwd=lwd, ...)
  }
  text(x=x_right + 0.02 * abs(diff(lastPP$x.lim)), y=y_tick, label=ticks, adj=0, ...)
  rect(x_left, y_bottom, x_right, y_top, col=colors, border=colors)

  text(x_left - width / 1.5, mean(bins) * height * length(tree$tip.label), labels=title, srt=90, ...)
  # text(x=x_left, y=max(y_top) + 0.02 * length(tree$tip.label), labels=title, adj=0, ...)
  # points(x=x_left, y=max(y_top) + 0.05 * length(tree$tip.label))

}
