function refreshPaperAward() {
    $.ajax({
        type: 'GET',
        url: 'php/paper_award.php',
        async: false,
        cache: false,
        timeout: 10000,
        success: function(result) {
            sh = JSON.parse(result);
            persons = sh['List'];
            //console.log(persons);
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
    $('#container').click(function() {
        document.documentElement.webkitRequestFullScreen();
    });
    refreshPaperAward();
    nextPerson();
    nextPerson();
    document.getElementById('pA').addEventListener('webkitAnimationIteration', function() {
        nextPerson();
    }, false);
    document.getElementById('pB').addEventListener('webkitAnimationIteration', function() {
        nextPerson();
    }, false);
});

