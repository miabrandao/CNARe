var m_labels, matrix;
var num_rows;
var fade_array = [1];
for (var i = 0; i < num_rows; ++i) {
  fade_array.push(1);
}
function fade() {
  var opacity;
  return function(d, i) {
    if (fade_array[d.index] == 0) {
      opacity = .0;
      fade_array[d.index] = 1;
    } else {
      opacity = .85;
      fade_array[d.index] = 0;
    }
    svg.selectAll(".chord path")
      .filter(function(d) { return d.source.index == i || d.target.index == i; })
      .transition()
      .style("opacity", opacity)
      .style("pointer-events", function() { return opacity == 0 ? "none" : "all"; });
  };
}
function hideTip() {
  d3.select("#tooltip")
    .style("visibility", "hidden");
}
function displayTip(d, i) {
  var src = d.source.index, tgt = d.target.index;
  d3.select("#tooltip")
    .style("visibility", "visible")
    .style("font-size", "10")
    .html("Informações: " + m_labels[src] + " e " + m_labels[tgt] + "<br />Numero de publicacoes em comum: " + matrix[src][tgt])
    .style("top", function() { return d3.event.pageY; })
    .style("left", function() { return d3.event.pageX; });
}
function loadChordSvg() {
  d3.json("http://localhost:3000/compare_more.json", function(error, json) {
    matrix = json.matrix;
    m_labels = json.names;
    num_rows = m_labels.length;
    var fill = d3.scale.category20b();
    var chord = d3.layout.chord()
      .padding(Math.PI / (3 * num_rows))
      .matrix(matrix)
      .sortGroups(d3.descending);
    var width = 960,
      height = 500,
      r1 = height / 2,
      innerRadius = Math.min(width, height) * .41,
      outerRadius = innerRadius * 1.12;
    var svg = d3.select("#svg_container").append("svg")
      .attr("width", width+200)
      .attr("height", height+200)
      .append("g")
      .attr("class", "diagram")
      .attr("transform", "translate(" + (width+200) / 2 + "," + "280)");
    var arcos_borda = svg.append("g").selectAll("path")
      .data(chord.groups)
      .enter().append("path")
	.attr("class", "arc")
	.style("fill", '#333')
	.attr("d", d3.svg.arc().innerRadius(innerRadius + 1).outerRadius(outerRadius))
	.on("click", fade())
	.append("text");
    var cordas = svg.append("g")
      .attr("class", "chord")
      .selectAll("path")
      .data(chord.chords)
      .enter()
	.append("path")
	.attr("d", d3.svg.chord().radius(innerRadius))
	.on("mouseover", displayTip)
	.on("mouseout", hideTip)
	.style("fill", function(d, i) { return fill(i); }) // '#1486AE'
	.style("opacity", .85);
    svg.append("g").selectAll(".arc")
      .data(chord.groups)
      .enter()
	.append("text")
	.attr("text-anchor", function(d) { return ((d.startAngle + d.endAngle) / 2) > Math.PI ? "end" : null; })
	.attr("transform", function(d) {
	    return "rotate(" + (((d.startAngle + d.endAngle) / 2) * 180 / Math.PI - 90) + ")"
	    + "translate(" + (r1 - 15) + ")"
	    + (((d.startAngle + d.endAngle) / 2) > Math.PI ? "rotate(180)" : "");
	    })
	.attr("font-family", "sans-serif")
	.attr("font-size", 14)
	.text(function(d, i) {
	  return m_labels[i];
	});
  });
}
