/* Copyright Boon Leng Cheong */
function insert_header() {
	var o = document.getElementById('template_header');
	if (o) {
		o.innerHTML
        = '<div class="globalheader">'
        + '    <div class="container">'
        + '        <ul>'
        + '            <li><a class="tip home" href="//www.ou.edu/web.html" alt="OU Home link"><span>OU Homepage</span></a></li>'
        + '            <li><a class="tip search" href="//www.ou.edu/ousearch.html" alth="OU Search link"><span>Search OU</span></a></li>'
        + '            <li><a class="tip social" href="//www.ou.edu/web/socialmediadirectory.html" alt="OU Social Media link"><span>The University of Oklahoma</span></a></li>'
        + '            <li class="wordmark">The University of Oklahoma</li>'
        + '        </ul>'
        + '    </div>'
        + '</div>'
        + '<div class="header">'
        + '    <div class="container">'
        + '        <img class="header_logo" src="' + baseName + 'images/header.svg" />'
        + '    </div>'
        + '</div>';
	}
	o = document.getElementById('navigation');
	if (o) {
        var str
        = '<ul>'
        + '<li><a href="' + baseName + 'index.php">ARRC Home</a></li>'
		+ '<li><a href="' + baseName + 'research.html">Research</a></li>'
		+ '<li><a href="' + baseName + 'education.html">Education</a></li>'
		+ '<li><a href="' + baseName + 'radars.html">Radar Systems</a></li>'
		+ '<li><a href="' + baseName + 'ril.html">Radar Innovations Laboratory</a></li>'
		+ '<li><a href="' + baseName + 'publications.html">Publications</a></li>'
        + '<li><a href="' + baseName + 'publications_awards.html">Student Journal Paper Award</a></li>'
		+ '<li><a href="' + baseName + 'people.html">People</a></li>'
		+ '<li><a href="' + baseName + 'contact.html">Contact Us</a></li>'
		+ '</ul>';
        
        o.innerHTML = str;
		setNavigationTab();
	}
    o = document.getElementById('quicklinks');
    if (o) {
        o.innerHTML
        = '<div class="title">Related Links</div>'
        + '<ul>'
        + '<li><a href="https://vpr-norman.ou.edu">Vice President for Research Office</a></li>'
        + '<li><a href="http://som.ou.edu">School of Meteorology</a></li>'
        + '<li><a href="http://ece.ou.edu">School of Electrical and Computer Engineering</a></li>'
        + '<li><a href="http://cees.ou.edu">School of Civil Engineering and Environmental Science</a></li>'
        + '<li><a href="http://nwc.ou.edu">National Weather Center</a></li>'
        + '<li><a href="http://caps.ou.edu">Center for Analysis and Prediction of Storms</a></li>'
        + '<li><a href="http://www.cimms.ou.edu">Cooperative Institute for Mesoscale Meteorological Studies</a></li>'
        + '<li><a href="http://climate.ok.gov">Oklahoma Climatological Survey</a></li>'
        + '<li><a href="http://www.nssl.noaa.gov">National Severe<br />Storms Laboratory</a></li>'
        + '<li><a href="http://www.roc.noaa.gov">NEXRAD Radar<br />Operations Center</a></li>'
        + '</ul>';
    }
	o = document.getElementById('template_footer');
	if (o) {
		t = new Date();
		o.innerHTML
        = '<div class="footer">'
        + '    <div class="container">'
        + '        <div class="footer_column">'
        + '            <img src="' + baseName + 'images/footerlogo.png" />'
        + '            <div class="address">'
        + '                <a href="http://arrc.ou.edu">Advanced Radar Research Center</a>'
        + '                3190 Monitor Ave.<br />Norman, OK 73019<br />Phone: 405.325.2871<br />Fax: 405.325.7043'
        + '            </div>'
        + '        </div>'
        + '        <div class="footer_column">'
        + '            <div class="footer_subcolumn">'
        + '            <a href="http://www.ou.edu/publicaffairs/WebPolicies/accessstatement.html">Accessibility</a>'
        + '            <a href="http://www.ou.edu/sustainability.html">Sustainability</a>'
        + '            <a href="http://ouhsc.edu/hipaa/">HIPAA</a>'
        + '            <a href="http://www.hr.ou.edu/employment/">OU Job Search</a>'
        + '            </div>'
        + '            <div class="footer_subcolumn">'
        + '            <a href="http://www.ou.edu/content/web/landing/policy.html">Policies</a>'
        + '            <a href="http://www.ou.edu/content/web/landing/legalnotices.html">Lega Notices</a>'
        + '            <a href="http://www.ou.edu/content/publicaffairs/WebPolicies/copyright.html">Copyright</a>'
        + '            <a href="http://www.ou.edu/content/web/resources_offices.html">Resources & Offices</a>'
        + '            </div>'
        + '        </div>'
        + '        <div class="footer_column social_icons">'
        + '            <a class="more" href="http://www.ou.edu/content/web/socialmediadirectory.html">more</a>'
        + '            <a class="youtube" href="https://www.youtube.com/user/UniversityofOklahoma">youtube</a>'
        + '            <a class="linkedin" href="http://www.linkedin.com/company/9310662">linkedin</a>'
        + '            <a class="twitter" href="http://twitter.com/OUARRC">twitter</a>'
        + '            <a class="facebook" href="http://www.facebook.com/OUARRC">facebook</a>'
        + '        </div>'
        + '        <img class="endorsement" src="' + baseName + 'images/wrn-logo.png" />'
        + '        <span id="update">'
        + '            Updated 1/5/2016 by <a class="inline" href="http://arrc.ou.edu">Advanced Radar Research Center</a> /'
        + '            <a class="inline" href="mailto:webmaster@arrc.ou.edu">webmaster@arrc.ou.edu</a>'
        + '        </span>'
        + '    </div>'
        + '</div>';
	}
    setNavigationTab();
	var agent = navigator.userAgent.toLowerCase();
	var is_mobile = (agent.indexOf('mobile')!=-1);
}

function setNavigationTab() {
    // Check if it is home
    var a = document.getElementById('navigation').getElementsByTagName('a');
    var o = document.getElementsByClassName('welcome');
    if (o.length) {
        a[0].setAttribute('class', 'active');
        a[0].setAttribute('className', 'active');
        return;
    }
    // Now, we check the active location
    var loc = window.location.href.substr(window.location.href.lastIndexOf('/') + 1).replace(/\.[^/.]+$/, '');
	for (var i=1; i<a.length; i++) {
		var nav = a[i].href.substr(a[i].href.lastIndexOf('/') + 1).replace(/\.[^/.]+$/, '');
        // console.log('nav =' + nav + ' : loc  = ' + loc + ' i = ' + nav.indexOf(loc));
		if (nav.indexOf(loc) != -1) {
            a[i].parentNode.style.display = 'inherit';
		}
        if (nav == loc) {
            a[i].setAttribute('class', 'active');
            a[i].setAttribute('className', 'active');
        }
	}
}

function insert_map() {
	o = document.getElementById('map');
	if (o) {
		o.innerHTML='<div style="display:block; width:698px; height:400px; border:1px solid #666;">'+
		'<iframe width="100%" height="100%" frameborder="0" scrolling="no" marginheight="0" marginwidth="0" src="https://maps.google.com/maps/ms?msa=0&amp;msid=209130770118348012147.0004c3d0cb9e0226ba557&amp;hl=en&amp;ie=UTF8&amp;t=m&amp;source=embed&amp;ll=35.201727,-97.439804&amp;spn=0.056108,0.119991&amp;z=13&amp;output=embed"></iframe><br /><small>View <a href="https://maps.google.com/maps/ms?msa=0&amp;msid=209130770118348012147.0004c3d0cb9e0226ba557&amp;hl=en&amp;ie=UTF8&amp;t=m&amp;source=embed&amp;ll=35.201727,-97.439804&amp;spn=0.056108,0.119991&amp;z=13" style="color:#900;text-align:left">ARRC related buildings</a> in a larger map</small>';
	}
}

function repositionSidebar() {
	var ff = 20;
	var body_height = $("body").height();
	var sidebar_height = $(".sidebar").height();
	var column_top = $(".column").offset().top;
	var bottom = body_height - sidebar_height - ff - 105; // padding at the bottom of body
	//var offset = bottom - $(window).scrollTop();
	var offset = bottom - column_top + ff;
	//document.getElementById('debug').innerHTML = $(window).scrollTop() + " > " + bottom + " <br/> " + body_height + " / " + sidebar_height + " / " + offset;
	if ($(window).scrollTop() < column_top - ff){
		$(".sidebar").css("position", "relative");
		$(".sidebar").css("top", "auto");
	} else if ($(window).scrollTop() > bottom) {
		//$(".sidebar").css("position", "fixed");
		//$(".sidebar").css("top", offset + "px");
		$(".sidebar").css("position", "relative");
		$(".sidebar").css("top", offset + "px");
	} else {
		$(".sidebar").css("position", "fixed");
		$(".sidebar").css("top", ff + "px");
	}
}

// Main
var baseName = '/';

if (self.location.pathname.indexOf("/arrc/") != -1) {
    baseName = '/arrc/';
}


// jQuery - document ready function
// $(document).ready(function(){
// 	if ( (document.getElementsByClassName('column')[0]) && (document.getElementsByClassName('sidebar')[0]) ) {
// 		$(window).scroll(function(){
// 			repositionSidebar();
// 		});
// 		$(window).resize(function(){
// 			repositionSidebar();
// 		});
// 	}
// });
