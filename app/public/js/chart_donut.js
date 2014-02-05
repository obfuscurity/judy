
var Donut = function(args) {

  var element = args.element;
  var dataset = args.dataset;
  var width = args.width || 100;
  var height = args.height || 100;
  var radius = Math.min(width, height) / 2;
  var colors = args.colors;
  var title = args.title;
  var color = null;
  var tipUnit = args.unit || '';

  if (typeof colors == 'undefined') {
    color = d3.scale.category20();
  } else if (typeof colors == 'function') {
    color = colors;
  } else {
    color = d3.scale.ordinal().range(colors);
  }

  var pie = d3.layout.pie().sort(null);
  var arc = d3.svg.arc().innerRadius(radius - (width / 3.5)).outerRadius(radius - width / 6);

  var tip = d3.tip().attr('class', 'd3-tip').html(function(d) { return d.value + tipUnit; });

  var svg = d3.select(element).append("svg")
    .attr("width", width)
    .attr("height", height)
    .append("g")
    .attr("transform", "translate(" + width / 2 + "," + height / 2 + ")");

  svg.call(tip);

  if (typeof title != 'undefined') {
    svg.append("title").text(title);
  }

  var path = svg.selectAll("path")
    .data(pie(dataset))
    .enter().append("path")
    .attr("fill", function(d, i) { return color(i); })
    .attr("d", arc)
    .on('mouseover', tip.show)
    .on('mouseout', tip.hide);
};
