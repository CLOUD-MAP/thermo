/* publications.js  Copyright (c) 2014-2015 Boon Leng Cheong */

/*
 * Title Caps
 * 
 * Ported to JavaScript By John Resig - http://ejohn.org/ - 21 May 2008
 * Original by John Gruber - http://daringfireball.net/ - 10 May 2008
 * License: http://www.opensource.org/licenses/mit-license.php
 */

(function(){
	var small = "(a|an|and|as|at|but|by|en|for|if|in|of|on|or|the|to|v[.]?|via|vs[.]?)";
	var punct = "([!\"#$%&'()*+,./:;<=>?@[\\\\\\]^_`{|}~-]*)";
  
	this.titleCaps = function(title){
		var parts = [], split = /[:.;?!] |(?: |^)["Ò]/g, index = 0;
		
		while (true) {
			var m = split.exec(title);

			parts.push( title.substring(index, m ? m.index : title.length)
				.replace(/\b([A-Za-z][a-z.'Õ]*)\b/g, function(all){
					return /[A-Za-z]\.[A-Za-z]/.test(all) ? all : upper(all);
				})
				.replace(RegExp("\\b" + small + "\\b", "ig"), lower)
				.replace(RegExp("^" + punct + small + "\\b", "ig"), function(all, punct, word){
					return punct + upper(word);
				})
				.replace(RegExp("\\b" + small + punct + "$", "ig"), upper));
			
			index = split.lastIndex;
			
			if ( m ) parts.push( m[0] );
			else break;
		}
		
		return parts.join("").replace(/ V(s?)\. /ig, " v$1. ")
			.replace(/(['Õ])S\b/ig, "$1s")
			.replace(/\b(AT&T|Q&A)\b/ig, function(all){
				return all.toUpperCase();
			});
	};
    
	function lower(word){
		return word.toLowerCase();
	}
    
	function upper(word){
	  return word.substr(0,1).toUpperCase() + word.substr(1);
	}
})();

function isIE () {
  var myNav = navigator.userAgent.toLowerCase();
  return (myNav.indexOf('msie') != -1) ? parseInt(myNav.split('msie')[1]) : false;
}

var os;
                        
function populate_publications() {
	var req = new XMLHttpRequest();
	if (req) {
		var handle_complete = function() {

			var sh = jQuery.parseJSON(req.responseText);
		
			var thisYear = (new Date()).getFullYear();

			// Initialize an empty string
			html = '';

			while (thisYear >= 2013) {                        

				// Count number of articles and book chapters first before populating
				a = 0;
				sh['Articles'].forEach(function(entry) {
					if (entry['Year'] == thisYear) { a++; }
				});
				b = 0;
				sh['Chapters'].forEach(function(entry) {
					if (entry['Year'] == thisYear) { b++; }
				});
				
				// If there is any articles or book chapters
				if (a > 2 || b > 0) {
					html += '<div class="paperYear">Year ' + thisYear + '<span class="showhide"></span></div>\n';
					html += '<div class="paperList">\n';
				}

				// If there is more than 0 entry
				if (a > 2) {
					html += '<ol>';
					sh['Articles'].forEach(function(article) {
						if (article['Year'] == thisYear) {
							html += '<li>' + article['Authors'].replace(/([A-Z]).([A-Z])/g,'$1. $2');
							html += ', ' + thisYear + ': ' + titleCaps(article['Title'].trim());
							if (html.substr(-1, 1) != '?') {
								html += ',';
							}
							html += ' <em>' + article['Journal'] + '</em>';
							if (article['Vol']) {
								html += ', <strong>' + article['Vol'] + '</strong>';
								if (article['No']) {
									html += '(' + article['No'] + ')';
								}
							}
							if (article['Pages']) {
								html += ', pp ' + article['Pages'].trim().replace(/\.$/, "").replace(/(\d+)\s-\s(\d+)/, '$1-$2');
							}
							html = html.replace(/\.$/, "");
							if (article['doi']) {
								html += ', ' + article['doi'].replace(/.$/, "");
							}
							html += '.</li>\n';
						}
					});
					html += '</ol>\n\n';
				}

				// If there is more than 0 entry
				if (b) {
					html += '<p><strong><u>BOOK CHAPTERS</u></strong></p>\n';
					html += '<ul>\n';
					sh['Chapters'].forEach(function(entry) {
						html += '<li>' + entry['Authors'] + ' (' + thisYear + '). ';
						html += entry['Title'];
						html += ', <em>' + entry['Book'] + '</em>';
						html += ' (pp ' + entry['Pages'].trim().replace(/\.$/, "") + ').';
						if (entry['Publisher']) {
							html += ' ' + entry['Publisher'].trim() + '.';
						}
						html += '</li>';
					});
					html += '</ul>\n\n';
				}
				
				// If there is any articles or book chapters
				if (a > 2 || b > 0) {
					html += '</div>\n\n';
				}
				
				// Move on to next year
				thisYear--;
			}
			document.getElementById('auto_populate').innerHTML = html;
                        
            // Get all the same class objects
			$('div.paperYear').click(function(d) {
				o = $(this).next('div.paperList');
				var n = o.children('ol').children().length;
				var w = Math.min(Math.max(15 * n, 200), 1000);
				o.css('min-height', 0).slideToggle(w, function() {
					$(this).css('min-height', '10px');
				});
			});
		}
		var handle_error = function() {
			document.getElementById('debug').innerHTML = 'Retrieval failed.';
		}
		req.open('GET', 'php/publications.php', true);   // Use this for PHP 5 < 5.2
		req.addEventListener('load', handle_complete, false);
		req.addEventListener('error', handle_error, false);
		req.send(null);
	} else {
		document.getElementById('debug').innerHTML = 'XHR Not Available.';
	}
}


