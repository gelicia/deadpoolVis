d3.selection.prototype.moveToFront = function() {
  return this.each(function(){
    this.parentNode.appendChild(this);
  });
};

function loadData(){
	loadCharacter();
	loadComics();
}

function loadCharacter(){
	d3.json('./data/character.json', function(err, data){
		console.log(data);
		data = data[0];
		var charName = d3.select("#charName");
		charName.text(data.name);

		if (data.description === ""){
			data.description = "No description available.";
		}
		var url = _.find(data.urls, function(d){return d.type == 'wiki';}).url;

		if (url !== undefined){ 
			data.description += "<br/><a href=\"" + url + "\">See the article for " + data.name + " in the Marvel Universe Wiki</a> ";	
		}

		console.log(charName.node());

		d3.select("#charDesc").html(data.description);
		d3.select("img#charImg").attr({
			"src": data.thumbnail.path + "." + data.thumbnail.extension,
			height: "100px",
			width: "100px"
			//"style" : "left: " + 
		}).classed("thumbPic", true);
	});
}

//["onsaleDate", "focDate", "unlimitedDate", "digitalPurchaseDate"] 
function loadComics(){
	d3.json('./data/comics.json', function(err, data){
		data.sort(function(a,b){
			var aSaleDate = _.find(a.dates, function(d){return d.type == 'onsaleDate';});
			var bSaleDate = _.find(b.dates, function(d){return d.type == 'onsaleDate';});

			//sort on saleDate, if that is not valid then by digitalPurchaseDate, then by unlimitedDate
			aSaleDate = aSaleDate.date.substring(0,1) == "-" ? _.find(a.dates, function(d){return d.type == 'digitalPurchaseDate';}) : aSaleDate;
			if(aSaleDate === undefined || aSaleDate.date.substring(0,1) == "-"){
				aSaleDate = _.find(a.dates, function(d){return d.type == 'unlimitedDate';});
			}
			bSaleDate = bSaleDate.date.substring(0,1) == "-" ? _.find(b.dates, function(d){return d.type == 'digitalPurchaseDate';}) : bSaleDate;
			if(bSaleDate === undefined || bSaleDate.date.substring(0,1) == "-"){
				bSaleDate = _.find(b.dates, function(d){return d.type == 'unlimitedDate';});
			}

			if (aSaleDate.date > bSaleDate.date){
				return 1;
			}
			else if (aSaleDate.date < bSaleDate.date){
				return -1;
			}
			else { return 0;}
		});

		console.log(data);
	});
}
