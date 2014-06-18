
   jQuery(function() {
        /** This code runs when everything has been loaded on the page */
        /* Inline sparklines take their values from the contents of the tag */
       jQuery('.inlinesparkline').sparkline(); 

        /* Sparklines can also take their values from the first argument 
        passed to the sparkline() function */
        var myvalues = [10,8,5,7,4,4,1];
       jQuery('.dynamicsparkline').sparkline(myvalues);

        /* The second argument gives options such as chart type */
       jQuery('.bulletgraph').sparkline('html', {type: 'bullet', height: '12px', width: '100px', targetWidth: '2', targetColor: 'red', rangeColors: ['grey','#e1e1e1']} );

        /* Use 'html' instead of an array of values to pass options 
        to a sparkline with data in the tag */
       jQuery('.inlinebar').sparkline('html', {type: 'bar', barColor: 'red'} );
    });
