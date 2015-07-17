function SvgToCanvas() {
  var svg = document.querySelectorAll("svg")[0];
  var canvas = document.getElementById("cnv");
  var oSerializer = new XMLSerializer();
  var sXML = oSerializer.serializeToString(svg);
  canvg(cnv, sXML);
}
function CanvasToPng() {
  SvgToCanvas();
  var canvas = document.getElementById("cnv");
  var data = canvas.toDataURL("image/png");
  data = data.replace("^data:image\/[^;]*/", "data:application/octet-stream;headers=Content-Disposition: attachment; filename=Canvas.png");
  this.href = data;
}
