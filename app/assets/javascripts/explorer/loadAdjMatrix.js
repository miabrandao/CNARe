var svg;
//var colors = ["#73F6F7", "rgb(40, 183, 198)", "#4C9BA8", "#097DA2", "#081A40"];
var colors = ["#73F6F7", "rgb(40, 183, 198)", "#1F8F9C", "#145B63", "#081A40"];
var width = 1170,
    height = 560; //294
var selection1, selection2;
var commonLinks;
function clearSvg() {
  d3.select("svg").remove();
  svg = d3.select("div#graph_d").append("svg")
    .attr("width", width)
    .attr("height", height);
  svg.append("rect")
    .attr("width", width)
    .attr("height", height)
    .style("fill", "#FFF");
}
function loadSubtitle() {
  var rect_size = 10;
  for (var i = 0; i <= 4; ++i) {
    svg.append("rect")
      .attr("width", rect_size)
      .attr("height", rect_size)
      .attr("x", width - 100 + (rect_size + 1) * i)
      .attr("y", 30)
      .style("fill", colors[i]);
    }
    svg.append("text")
      .text("less")
      .attr("x", width - 122)
      .attr("y", 38)
      .style("font-family", "sans-serif")
      .style("font-size", rect_size + "px")
    svg.append("text")
      .text("more")
      .attr("x", width - 44)
      .attr("y", 38)
      .style("font-family", "sans-serif")
      .style("font-size", rect_size + "px");
    svg.append("text")
      .text("Statistics")
      .attr("x", 40)
      .attr("y", 420)
      .style("font-family", "sans-serif")
      .style("font-size", 15);
    svg.append("text")
      .text("Number of researchers: " + (selection1.length + selection2.length))
      .attr("x", 45)
      .attr("y", 440)
      .style("font-family", "sans-serif")
      .style("font-size", 12);
    svg.append("text")
      .text("Number of links: " + commonLinks.length)
      .attr("x", 45)
      .attr("y", 455)
      .style("font-family", "sans-serif")
      .style("font-size", 12);
}
function loadAdjMatrix(s1, s2) {
  var rect_size = 10, padding = 3;
  clearSvg();
  var div = d3.select(".tooltip");
  d3.json("http://localhost:3000/explorer.json", function(error, json) {
    if (s1 == 1 && s2 == 2) {
      selection1 = json.g1g2;
      selection2 = json.g2g1;
      commonLinks = json.linksg1g2;
    } else if (s1 == 1 && s2 == 3) {
      selection1 = json.g1g3;
      selection2 = json.g3g1;
      commonLinks = json.linksg1g3;
    } else {
      selection1 = json.g2g3;
      selection2 = json.g3g2;
      commonLinks = json.linksg2g3;
    }
    if (commonLinks.length == 0) {
      svg.append("text")
	.text("No common links")
	.style("font-family", "sans-serif")
	.style("font-size", 12)
	.attr("x", width / 2)
	.attr("y", height / 2);
      return;
    }
    var nRows = selection1.length;
    var nColumns = selection2.length;
    var g1 = [];
    selection1.forEach(function(d, i) {
      g1.push({id: d.id, name: d.name});
    });
    var g2 = [];
    selection2.forEach(function(d, i) {
      g2.push({id: d.id, name: d.name});
    });
    var matrix = new Array(nRows);
    for (var i = 0; i < nRows; ++i) {
      matrix[i] = new Array(nColumns);
      for(var j = 0; j < nColumns; ++j)
	matrix[i][j] = 0;
    }
    var max = 0, min = -1;
    commonLinks.forEach(function(d, i) {
      var j, k;
      for (j = 0; j < g1.length; ++j)
	if (d.source == g1[j].id) break;
      for (k = 0; k < g2.length; ++k)
	if (d.target == g2[k].id) break;
      matrix[j][k] = d.value;
      if (min == -1)
	min = d.value;
      if (min > d.value)
	min = d.value;
      if (d.value > max) {
	max = d.value;
      }
    });
    var row_order = [];
    for (var i = 0; i < nRows; ++i) {
      var row_max = 0, column_number = 0;
      for (var j = 0; j < nColumns; ++j)
	if (matrix[i][j] > row_max) {
	  row_max = matrix[i][j];
	  column_number = j;
	}
      row_order.push({max: row_max, row: i, column: column_number});
    }
    row_order.sort(function(a, b) {
	if (b.max == a.max)
	  return a.column - b.column;
	return b.max - a.max;
    });
    var g1_aux = [];
    for (var i = 0; i < nRows; ++i)
      g1_aux.push(g1[row_order[i].row]);
    g1 = g1_aux;
    var matrix_aux = new Array(matrix[row_order[0].row]);
    for (var i = 1; i < nRows; ++i)
      matrix_aux.push(matrix[row_order[i].row]);
    matrix = matrix_aux;
    var t_column1 = [];
    for (var i = 0; i < nRows; ++i)
      t_column1.push(matrix[i][0]);
    var t_matrix = new Array(t_column1);
    for (var i = 1; i < nColumns; ++i) {
      var t_column = [];
      for (var j = 0; j < nRows; ++j) {
	t_column.push(matrix[j][i]);
      }
      t_matrix.push(t_column);
    }
    var column_order = [];
    for (var i = 0; i < nColumns; ++i) {
      var column_max = 0, row_number = 0;
      for (var j = 0; j < nRows; ++j)
	if (t_matrix[i][j] > column_max) {
	  column_max = t_matrix[i][j];
	  row_number = j;
	}
      column_order.push({max: column_max, column: i, row: row_number});
    }
    console.log(column_order);
    column_order.sort(function(a, b) {
	if (b.max == a.max)
	  return a.row - b.row;
	return b.max - a.max;
    });
    var g2_aux = [];
    for (var i = 0; i < nColumns; ++i)
      g2_aux.push(g2[column_order[i].column]);
    g2 = g2_aux;
    var t_matrix_aux = new Array(t_matrix[column_order[0].column]);
    for (var i = 1; i < nColumns; ++i)
      t_matrix_aux.push(t_matrix[column_order[i].column]);
    t_matrix = t_matrix_aux;
    for (var i = 0; i < nRows; ++i)
      for (var j = 0; j < nColumns; ++j)
	matrix[i][j] = t_matrix[j][i];
    loadSubtitle();
    var matrix_position = [311, 100];
    var scale = d3.scale.linear()
      .domain([min, max])
      .rangeRound([0, 4]);
    var matrix_g = svg.append("g")
      .attr("class", "matrix");
      //.attr("transform", "translate(" + matrix_position[0] + "," + matrix_position[1] + ")");
    var columns_g = matrix_g.append("g").attr("class", "columns");
    var columns = columns_g.selectAll(".column")
      .data(g2)
      .enter()
	.append("g")
	  .attr("class", "column")
	  .attr("transform", function(d, i) { return "translate(" + ((rect_size + padding) * (i + 1) - 3) + ") rotate(-90)"; })
	  .append("text")
	    .attr("font-size", rect_size + "px")
	    .attr("font-family", "sans-serif")
	    .text(function(d, i) { return g2[i].name; });
    var rows = matrix_g.selectAll(".row")
      .data(matrix)
      .enter()
      .append("g")
	.attr("class", "row")
	.on("mouseover", function () {
	  var num = Math.floor(d3.mouse(this)[0] / (rect_size + padding));
	  if (num >= nColumns)
	    return;
	  d3.select(d3.selectAll(".column")[0][num]).style("fill", "#04A");
	  d3.select(this).style("fill", "#04A");
	})
	.on("mouseout", function() {
	  d3.selectAll(".column").style("fill", "#000");
	  d3.select(this).style("fill", "#000");
	})
	.each(function(d, i) {
	  d3.select(this).selectAll("rect")
	    .data(d)
	    .enter()
	      .append("rect")
		.attr("class", "rect")
		.attr("height", rect_size)
		.attr("width", rect_size)
		.attr("x", function(d, j) { return (rect_size + padding) * j; })
		.attr("y", 5 + (rect_size + padding) * i)
		.style("fill", function (d, j) {
		  if (matrix[i][j] == 0)
		    return "#EEE";
		  return colors[scale(matrix[i][j])];
		})
		.on("mouseover", function(d, j) {
		  if (matrix[i][j] == 0) return;
		  div.transition()
		    .duration(200)
		    .style("opacity", .9);
		  div.html("frequency: " + matrix[i][j])
		    .style("left", d3.event.pageX - 75 + "px")
		    .style("top", d3.event.pageY - 15 + "px");
		  })
		.on("mouseout", function(d) {
		  div.transition()
		    .duration(500)
		    .style("opacity", 0);
		});
	  d3.select(this)
	    .append("text")
	      .text(g1[i].name)
	      .attr("x", 5 + nColumns * (rect_size + padding))
	      .attr("y", 4 + (rect_size + padding) * (i + 1) - 1)
	      .attr("font-size", rect_size + "px")
	      .attr("font-family", "sans-serif");
	});
   var shift_h = (width - matrix_position[0] - d3.select(".matrix")[0][0].getBBox().width) / 2;
   //var shift_v = (height - d3.select(".matrix")[0][0].getBBox().height - d3.select(".columns")[0][0].getBBox().width) / 2;
   var shift_v = (height - d3.select(".matrix")[0][0].getBBox().height) / 2 + 150;
   matrix_g
      .attr("transform", "translate(" + (matrix_position[0] + shift_h) + "," + shift_v + ")");
  });
}
