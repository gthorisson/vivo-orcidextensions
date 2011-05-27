
/*

This code was created by ORCID as part of the VIVO Collaborative Research Projects Program.

Author: Gudmundur A. Thorisson <gthorisson@gmail.com>

See also https://github.com/gthorisson/vivo-orcidextensions


THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

*/

/*

This client-side JavaScript works with the form specified in addPublicationToPerson.jsp 
and provides the following functionality:

 - send a request to the external bibliographic system, retrieve the results and display in table
 - for the publication the user selects from the table, retrieve full bibliographic
   details from the external system and populate the form.
   

*/


// Configure the Ajax request to be fired when user clicks the Search button
$('#externalPubLookupSubmit').click( function(){ searchExternal() } );
// OR hits the Enter key
$('#externalPubLookupTerms').keypress(function(e) {	
	if(e.which ==13) {
	   e.preventDefault();
	   $('#externalPubLookupSubmit').click();
	}
});

		
// The main Ajax function
function searchExternal () {
      $('#externalPubLookupResultListing').empty(); // Remove any previous result listing
      $('#externalPubLookupDetails').hide(); // Hide external pub details

      $('#externalPubLookupStatus > span').text('Searching CrossRef bibliographic metadata')
      $('#externalPubLookupStatus').show(); // Show progress indicator
      var queryString = $('#externalPubLookupTerms').val();
      
	  $.getJSON('/jruby/bibliosearch?',
	  {
		      query: queryString
	      },
          function(data) {
   	          $('#externalPubLookupStatus').hide(); // hide progress indicator
   	            
   	            var bibdata = []; // This will be populated in the callback and then fed to DataTable
	    	    $.each(data, function(i,item){
	    	    	bibdata.push([item.fullCitation,item.doi,null]);	    	    		    	        
	    	    });
	    	    
	    	    // ToDo: error handling, nee to catch 500 or other non-200 responses from the external search service
	    	    // and display an error msg to the user.
	    	    
   	            // Use the excellent DataTables plugin for jQuery to create a pretty table from data collected above
                $('#externalPubLookupResultListing').html( '<table cellpadding="0" cellspacing="0" border="0" class="display" id="externalPubTable"></table>' );
                var oTable =  $('#externalPubTable').dataTable({
     	        	"bFilter": false,
     	        	"bPaginate": false,
     	        	"bAutoWidth": true,
     	        	"aaData": bibdata,
     	        	"aoColumns": [
     	        	           { "sTitle": "Citation" },
     	        	           { "sTitle": "DOI raw","bVisible": false },
     	        	           { "sTitle": "DOI",
     	        	        	 // Special handling to display hyperlinked DOI name
     	        	        	 "fnRender": function(obj) {
     	      		    		     	var doi = obj.aData[1]; // grab raw DOI from other column
     	      			    	    	var doi_url = 'http://dx.doi.org/' + doi;
        	      		    		    var doi_formatted = 'doi:<a href="' + doi_url + '">' + doi + '</a>';        	      		    		    
        	      		    		    return doi_formatted; // This should be displayed in the table
     	   		            		}
     	        	       	   },
     	        	       	   ],
     	        	  "fnRowCallback": function( nRow, aData, iDisplayIndex, iDisplayIndexFull ) {
     	        	      	$(nRow).click( function() {
       	     	              var doi = aData[1];
     	 	    	          $('#externalPubLookupResultListing').empty(); // Remove result listing
     	 	    	          $('#externalPubLookupDetails').hide();
     	 	    	          $('#externalPubLookupStatus > span').text('Retrieving metadata for doi:'+doi)
     		    	          $('#externalPubLookupStatus').show(); // Show progress indicator again     		    	          

     		    	    	  $.get('/jruby/bibliofetch?doi=' + doi, function(bibdetails_rdf) {
     		    	   	          $('#externalPubLookupStatus').hide(); // hide progress indicator

        	    	    	   	  // Now that the bibliographic details are in hand, need to fill out form. The
     		    	   	          // data are provided as RDF, so we create a mini-triplestore and pull out
     		    	   	          // the stuff we need from there.
     			    	    	  var doi_url = 'http://dx.doi.org/' + doi;
     			    	    	  var rdf = $.rdf().load($.parseJSON(bibdetails_rdf));
     		    	    	      rdf.prefix('dc','http://purl.org/dc/terms/')
     		    	    	         .prefix('bibo','http://purl.org/ontology/bibo/')
     		    	    	         .prefix('prism','http://prismstandard.org/namespaces/basic/2.1/')
     		    	    	         .prefix('owl','http://www.w3.org/2002/07/owl#')
   		    	    	             .prefix('rdfs','http://www.w3.org/2000/01/rdf-schema#');
     		    	    	           		    	    		  

     		    	    	      // Extract the triples we want by querying the RDF object in hand. First
     		    	    	      // let's do the literals.
     		    	    	      
     		    	    	      // ToDo: use the publication type from the RDF - a subclass assertion.
      		    	    	      //    can we set the pubType dropdown based this?

     		    	    	       
            	    	          // Set pub title field
     		    	    	      rdf.where('<' + doi_url + '> dc:title ?title')
     		    	    	         .each(function(index) {
     		    	    	            $('#relatedIndLabel').focus();
         		    	    	        $('#relatedIndLabel').val(this.title.value);
     		    	    	         });
     		    	    	           		    	    	      
            	    	          // Set pub volume field
     		    	    	      rdf.where('<' + doi_url + '> bibo:volume ?volume')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubVolume').val(this.volume.value);
     		    	    	         });
     		    	    	      
            	    	          // Set pub volume field
     		    	    	      rdf.where('<' + doi_url + '> bibo:issue ?issue')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubIssue').val(this.issue.value);
     		    	    	         });
     		    	    	      
            	    	          // Set pub pageStart field
     		    	    	      rdf.where('<' + doi_url + '> bibo:pageStart ?pageStart')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubPageStart').val(this.pageStart.value);
     		    	    	         });

            	    	          // Set pub pageEnd field
     		    	    	      rdf.where('<' + doi_url + '> bibo:pageEnd ?pageEnd')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubPageEnd').val(this.pageEnd.value);
     		    	    	         });
     		    	    	      
            	    	          // Set pub DOI field
     		    	    	      rdf.where('<' + doi_url + '> bibo:doi ?doi')
     		    	    	         .each(function(index) {
         		    	    	        $('#pubDOI').val(this.doi.value);
     		    	    	         });

     		    	    	      // Now do the non-literal assertions, involving several resources that need to be created
     		    	    	      
            	    	          // The pub date: this needs an instance of DateTimeValue which holds the date string itself
     		    	    	      // precision indicator (year, month etc.).
     		    	    	      rdf.where('<' + doi_url + '> dc:date ?date')
     		    	    	         .each(function(index) {
     		    	    	        	// figure out year precision from inspecting the string
         		    	    	        $('#pubDateTime').val(this.date.value);
         		    	    	        $('#pubDateTimePrecisionUri').val('http://vivoweb.org/ontology/core#yearMonthDayPrecision')  ;  // (this.date.value);
     		    	    	         });

     		    	    	      // The pub venue: this needs an instance of InformationResource
      		    	    	      rdf.where('?pubVenue dc:hasPart <' + doi_url + '>')
      		    	    	         .where('?pubVenue dc:title ?title')
      		    	    	         .where('?pubVenue bibo:issn ?issn')
      		    	    	         .where('?pubVenue a ?type')
  		    	    	             .each(function(index) {
      		    	    	           $('#venueUri').val(this.pubVenue.value);
      		    	    	           $('#venueTitle').val(this.title.value);
      		    	    	           $('#venueISSN').val(this.issn.value);
      		    	    	           $('#venueTypeUri').val(this.type.value);
  		    	    	          });
     		    	    	    		  
     		    	    	      
     		    	    	      // ToDo: Tease out each of the dc:creator resources too and add them to form.. how? s
      		    	    	      //rdf.where('<' + doi_url + '> dc:creator ?creator')
  		    	    	          //   .each(function(index) {
  		    	    	          //});
    		    	    	         
      		    	    	      
                                  // Now that biblio details are filled out, show the form.
      		    	    	      $('#externalPubLookupDetails').show();
     				    	      
      		    	    	      // For later: add some post-processing here and have UI suggest to user that the pub venue might
      		    	    	      // be already in system. Same for authors. A basic form of supervised disambiguation. 
     		    	    	  });

     	        	       		
     	        	       	} );
   	     	        	  return nRow; // DataTables needs this returned

     	        	     }     	        	       	   
     	        	            
       	        });
	    	    });     	        

}


