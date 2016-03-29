function refreshPaperAward() {
    $.ajax({
        type: 'GET',
        url: 'php/paper_award.php',
        async: false,
        cache: false,
        timeout: 10000,
        success: function(result) {
            persons = JSON.parse(result)['List'];
			var year = '';
			var str = ''
            for (var i in persons) {
            	person = persons[i];
            	// console.log(person);
            	if (year != person['Year']) {
            		year = person['Year'];
            		if (str) {
            			str += '</ul>';
            		}
            		str += '<h3>' + person['Year'] + '</h3>'
            		     + '<ul>' + "\n";
            	}
            	str += '<li>' + person['Name'] + ': ' + person['Title'] + ', <em>' + person['Journal'] + '</em>.</li>' + "\n";
            }
			var o = document.getElementById('student_paper_award_papers');
			if (o) {
				o.innerHTML = str;
			}
        },
        error: function(error) {
			console.log('Error in $.ajax');
        }
    });
}

function makeHTML(person) {
	html = '';
	if (person['hasPic']) {
		html += '<img class="people" src="people_images/' + person['Email'] + '.jpg" />';
	} else {
		html += '<img class="people" src="people_images/blank.jpg" />';
	}
	html += '<span class="year">' + person['Year'] + '</span>' +
	        '<span class="name">' + person['Name'] + '</span>' + 
            '<span class="affiliation">' + person['Affiliation'] + '</span>' +
            '<div class="titleWrapper"><span class="title">' + person['Title'] + '</span></div>' +
            '<span class="journal">' + person['Journal'] + '</span>';
	return html;
}

function nextPerson() {
    if (state == 0) {
    	state = 1;
		document.getElementById('pA').innerHTML = makeHTML(persons[personIndex]);
    } else {
    	state = 0;
		document.getElementById('pB').innerHTML = makeHTML(persons[personIndex]);
    }

    document.getElementById('slideShowDebug').innerHTML = 'personIndex = ' + personIndex
                                   + ' ; person = ' + persons[personIndex]['Name']
                                   + ' ; state = ' + state;

	personIndex = personIndex == persons.length - 1 ? 0 : personIndex + 1;

	if (personIndex == 0) {
		refreshPaperAward();
	}
}

state = 0;
personIndex = 0;
persons = new Array([{'Name': 'Jane Doe', 'Affiliation': 'Advanced Radar Research Center', 'Journal': 'Mon. Wea. Rev.', 'Email': '', 'Title': 'Journal Title', 'hasPic': 0}]);

$(document).ready(function() {
    refreshPaperAward();
    $(window).scroll(function() {
                     	var scroll = Math.min(Math.max($(window).scrollTop() * 0.5, 0), 110);
    					$('#student_paper_award_trophy').css('transform', 'translate(20px, ' + scroll + 'px)');
    					});
});

