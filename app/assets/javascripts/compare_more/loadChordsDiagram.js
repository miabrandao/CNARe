var m_labels, matrix;
var num_rows;
var fade_array = [0];
var svg;
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
function hideChordTip() {
  d3.select("#tooltip")
      .style("visibility", "hidden");
}
function displayChordTip(d, i) {
  var src = d.source.index, tgt = d.target.index;
  console.log(matrix);
  d3.select("#tooltip")
    .style("visibility", "visible")
    .style("font-size", "10px")
    .html("Informações: " + m_labels[src] + " e " + m_labels[tgt] + "<br />Numero de publicacoes em comum: " + matrix[src][tgt])
    .style("top", function() { return d3.event.pageY + 10 + "px"; })
    .style("left", function() { return d3.event.pageX + "px"; });
}
function loadChordSvg(o1, o2, o3) {
  d3.json("http://localhost:3000/compare_more.json", function(error, json) {
    var width = 960,
      height = 400,
      r1 = height / 2 + 5,
      innerRadius = Math.min(width, height) * .41,
      outerRadius = innerRadius * 1.12;
    d3.select("svg").remove();
    svg = d3.select("#svg_container").append("svg")
      .attr("width", width + 200)
      .attr("height", height + 200)
      .append("g")
      .attr("class", "diagram")
      .attr("transform", "translate(" + (width + 200) / 2 + "," + "300)");
    matrix = json.matrix;
    m_labels = json.names;
    num_rows = m_labels.length;
    var fade_value = .85;
    if (o3 == 1)
      fade_value = 0;
    for (var i = 0; i < num_rows; ++i) fade_array.push(fade_value);
    var matrix_width = new Array(new Array(num_rows));
    for (var i = 1; i < num_rows; ++i)
      matrix_width.push(new Array(num_rows));
    for (var i = 0; i < num_rows; ++i)
      for (var j = 0; j < num_rows; ++j)
	matrix_width[i][j] = matrix[i][j];
    if (o1 == 0)
      for (var i = 0; i < num_rows; ++i) matrix_width[i][i] = 0;
    if (o2 == 1) {
      for (var i = 0; i < num_rows; ++i)
	for (var j = 0; j < num_rows; ++j)
	  if (matrix_width[i][j] != 0)
	    matrix_width[i][j] = 1;
    }
    var fill = d3.scale.category20b();
    var chord = d3.layout.chord()
      .padding(Math.PI / (3 * num_rows))
      .matrix(matrix_width)
      .sortGroups(d3.descending);
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
	.on("mouseover", displayChordTip)
	.on("mouseout", hideChordTip)
	.style("fill", function(d, i) { return fill(i); }) // '#1486AE'
	.style("opacity", function() { return (o3 == 0) ? .85 : 0 })
	.style("pointer-events", function() { return o3 == 1 ? "none" : "all"; });
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
	.attr("font-size", 12)
	.text(function(d, i) {
	  return m_labels[i];
	});
  });
}
