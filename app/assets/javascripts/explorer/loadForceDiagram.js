var edges = [];
var nodes = [];
function loadSubtitleForce(svg, color, institutions) {
  var subtitle_group = svg.append("g").attr("class", "subtitle");
  var rects = subtitle_group.append("g").attr("class", "rect");
  var tmp = institutions.length;
  if (tmp > 10) {
    var res_num = 0;
    for (var i = 9; i < tmp; ++i)
      res_num += institutions[i].researchers;
    institutions.length = 9;
      institutions.push({instituicao: tmp - 9 + " other(s)", researchers: res_num});
  }
  rects.selectAll("rect") 
    .data(institutions) 
    .enter()
      .append("rect")
      .attr("x", 45)
      .attr("y", function(d, i) { return 314 + i * 13; })
      .attr("width", 10)
      .attr("height", 10)
      .style("fill", function(d, i) { return color[i]; });
  subtitle_group.selectAll("text")
    .data(institutions)
    .enter()
      .append("text")
      .text(function(d) { return d.instituicao + ", with " + d.researchers + " node(s)"; })
      .attr("x", 60)
      .attr("y", function(d, i) { return 323 + i * 13;})
      .style("font-family", "sans-serif")
      .style("font-size", "12px")
      .style("fill", "#000");
  subtitle_group.attr("transform", "translate(950, -300)");
  svg.append("text")
    .text("Statistics")
    .attr("x", 40)
    .attr("y", 420)
    .style("font-family", "sans-serif")
    .style("font-size", 15);
  svg.append("text")
    .text("Number of researchers: " + nodes.length)
    .attr("x", 45)
    .attr("y", 440)
    .style("font-family", "sans-serif")
    .style("font-size", 12);
  svg.append("text")
    .text("Number of links: " + edges.length)
    .attr("x", 45)
    .attr("y", 455)
    .style("font-family", "sans-serif")
    .style("font-size", 12);
}
function loadForceDiagram() {
  d3.select("svg").remove();
  edges = [];
  nodes = [];
  var fisheye = d3.fisheye.circular()
    .radius(50)
    .distortion(3);
  div = d3.select(".tooltip");
//  var color = d3.scale.category20b();
  //var color = d3.scale.category10();
  var color = ["#1F77B4", "#FF7F0E", "#2CA02C", "#D62728", "#9467BD", "#8C563B", "#E377C2", "#BCBD22", "#17BECF", "#7F7F7F"];
  var radius = 3;
  var width = 1170,
    height = 560;
  var svg = d3.select("div#graph_d").append("svg")
    .attr("width", width)
    .attr("height", height);
  svg.append("rect")
    .attr("width", width)
    .attr("height", height)
    .style("fill", "#FFF");
  var force = d3.layout.force()
    .gravity(2.4)
    .linkStrength(1.2)
    .linkDistance(.1)
    .alpha(.9)
    .charge(-950)
    .size([width + 218, height]);
  d3.json("http://localhost:3000/explorer.json", function(error, json) {
    json.Links.forEach(function(e) { 
      var sourceNode = json.Nodes.filter(function(n) { return n.id == e.source; })[0],
      targetNode = json.Nodes.filter(function(n) { return n.id == e.target; })[0];
      edges.push({ source: sourceNode, target: targetNode, value: e.value, count: e.count });
    });
    var institutions = json.Institutions;
    institutions.sort(function(a, b) {
      return b.researchers - a.researchers;
    });
    nodes = json.Nodes;
    force.nodes(json.Nodes)
      .links(edges)
      .start();
    var link_group = svg.append("g")
      .attr("class", "link");
    var link = link_group.selectAll(".link")
      .data(edges)
      .enter()
      .append("line")
      .attr("class", "link")
      .style("stroke", "#AAA")
      .style("stroke-width", "1.5");
    var type = ["circle", "triangle-up", "square"];
    loadSubtitleForce(svg, color, institutions);
    var node_group = svg.append("g")
	.attr("class", "node");
    var node = node_group.selectAll(".node")
      .data(json.Nodes)
      .enter()
      .append("path")
      .attr("class", "node")
      .attr("d", d3.svg.symbol().type(function (d) { return type[d.group - 1]; }).size(60))
      .style("fill", function(d) {
	var i = 0;
	var inst_length = institutions.length;
	if (inst_length >= 10)
	  inst_length = 9;
	while(i < inst_length && (institutions[i].instituicao.localeCompare(d.instituicao)))
	  ++i;
	return color[i];
      })
      .on("mouseover", function(d) {
	div.transition()
	  .duration(200)
	  .style("opacity", .9);
	div.html(d.name)
	  .style("left", (d3.event.pageX) + "px")
	  .style("top", (d3.event.pageY - 28) + "px");
	})                  
      .on("mouseout", function(d) {
	div.transition()
	  .duration(500)
	  .style("opacity", 0);
      });
    svg.on("mousemove", function() {
      fisheye.focus(d3.mouse(this));
      node.attr("transform", function(d) { return "translate(" + fisheye(d).x + ", " + fisheye(d).y + ")";})
	.attr("d", d3.svg.symbol().type(function (d) { return type[d.group - 1]; }).size(function(d) { return 60 * fisheye(d).z; }));
      link.attr("x1", function(d) { return fisheye(d.source).x; })
	.attr("y1", function(d) { return fisheye(d.source).y; })
	.attr("x2", function(d) { return fisheye(d.target).x; })
	.attr("y2", function(d) { return fisheye(d.target).y; });
    });
    force.on("tick", tick);
    function tick() {
      node.attr("transform", function(d) { return "translate(" + d.x + ", " + d.y + ")"; });
      link.attr("x1", function(d) { return d.source.x; })
	.attr("y1", function(d) { return d.source.y; })
	.attr("x2", function(d) { return d.target.x; })
	.attr("y2", function(d) { return d.target.y; });
    };
  });
}
