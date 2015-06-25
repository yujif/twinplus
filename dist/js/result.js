    // tooltip demo
    $('.tooltip-demo').tooltip({
        selector: "[data-toggle=tooltip]",
        container: "body"
    })

    // popover demo
    $("[data-toggle=popover]")
        .popover()

    $.extend( $.fn.dataTable.defaults, {
    "paging": false,
    "lengthChange": false,
    "searching": true,
     "autoWidth": false,
    "ordering": true,
    "info": false,
    "language": {
      "zeroRecords": "該当データがありません。",
      "emptyTable" : "該当データがありません。",
      "loadingRecords" : "ロード中",
      "processing" : "処理中...",
      "search" : "検索: "
    }
} );


        $('.add_credits').change(function(){

                section_name = $(this).data("section");
                console.log(section_name)
                now = parseFloat( $(".earned_credits_" + section_name ).html() );
                now_un = parseFloat( $(".un_earned_credits_" + section_name).html() );
                req = parseFloat( $(".require_credits_" + section_name ).html() );
                add_credit = parseFloat( $(this).data("credit") );

                if ($(this).is(':checked')) {
                    $(".earned_credits_" + $(this).data("section") ).html( now + add_credit );
                    $(".un_earned_credits_" + $(this).data("section") ).html( now_un - add_credit );
                    percent = 100 * ( (now + add_credit) / req );
                    add_percent = add_credit / req * 100.0;
                } else {
                    $(".earned_credits_" + $(this).data("section") ).html( now - add_credit );
                    $(".un_earned_credits_" + $(this).data("section") ).html( now_un + add_credit );
                    percent = 100 * ( (now - add_credit) / req );
                    add_percent = add_credit / req * 100.0 * -1;
                }
                console.log(percent);

                $("#earned_percent_" + $(this).data("section") ).html( percent.toFixed(1) );

                //プログレスバー用
                //追加する単位の%を求める

                if ($(this).data("status") == "registed") {
                    //青を減らして、緑を増やす
                    new_css_percent_earned =  parseFloat( $("#earned_progress_" + $(this).data("section") ).data("percent") ) + parseFloat( add_percent );
                    new_css_percent_registed =  parseFloat( $("#registed_progress_" + $(this).data("section") ).data("percent") ) - parseFloat( add_percent );
                    $("#earned_progress_" + $(this).data("section") ).css("width", new_css_percent_earned + "%");
                    $("#earned_progress_" + $(this).data("section") ).data("percent", new_css_percent_earned);
                    $("#registed_progress_" + $(this).data("section") ).css("width", new_css_percent_registed + "%");
                    $("#registed_progress_" + $(this).data("section") ).data("percent", new_css_percent_registed);

                }
                if ($(this).data("status") == "unregisted") {
                    new_css_percent =  parseFloat( $("#addition_progress_" + $(this).data("section") ).data("percent") ) + parseFloat( add_percent );
                    $("#addition_progress_" + $(this).data("section") ).css("width", new_css_percent + "%");
                    $("#addition_progress_" + $(this).data("section") ).data("percent", new_css_percent);
                }
        });


        $('.all_check_unregisted').change( function() {
            section_name = $(this).data("section");

            if ($(this).is( ':checked' )) {
            //     //選択時：先に全選択解除してから全選択
                 //    $("#addition_progress_" + $(this).data("section") ).css("width",  "0%");
                 //    $("#addition_progress_" + $(this).data("section") ).data("percent", 0);
                 // $('input[name="check_unregisted_' + section_name + '"]').prop('checked', true).change();
            }else{
            //解除時：値をリセット
                    $("#addition_progress_" + $(this).data("section") ).css("width",  "0%");
                    $("#addition_progress_" + $(this).data("section") ).data("percent", 0);
            }

            $('input[name="check_unregisted_' + section_name + '"]').prop('checked', this.checked).change();

        } );
        $('.all_check_registed').change( function() {
            section_name = $(this).data("section");
            $('input[name="check_registed_' + section_name + '"]').prop('checked', this.checked).change();
        } );



        /**
 * Data can often be a complicated mix of numbers and letters (file names
 * are a common example) and sorting them in a natural manner is quite a
 * difficult problem.
 *
 * Fortunately a deal of work has already been done in this area by other
 * authors - the following plug-in uses the [naturalSort() function by Jim
 * Palmer](http://www.overset.com/2008/09/01/javascript-natural-sort-algorithm-with-unicode-support) to provide natural sorting in DataTables.
 *
 *  @name Natural sorting
 *  @summary Sort data with a mix of numbers and letters _naturally_.
 *  @author [Jim Palmer](http://www.overset.com/2008/09/01/javascript-natural-sort-algorithm-with-unicode-support)
 *
 *  @example
 *    $('#example').dataTable( {
 *       columnDefs: [
 *         { type: 'natural', targets: 0 }
 *       ]
 *    } );
 */

(function() {

/*
 * Natural Sort algorithm for Javascript - Version 0.7 - Released under MIT license
 * Author: Jim Palmer (based on chunking idea from Dave Koelle)
 * Contributors: Mike Grier (mgrier.com), Clint Priest, Kyle Adams, guillermo
 * See: http://js-naturalsort.googlecode.com/svn/trunk/naturalSort.js
 */
function naturalSort (a, b) {

    if (a == "A+"){
        a = "0";
    }
    if (b == "A+"){
        b = "0";
    }

    var re = /(^-?[0-9]+(\.?[0-9]*)[df]?e?[0-9]?$|^0x[0-9a-f]+$|[0-9]+)/gi,
        sre = /(^[ ]*|[ ]*$)/g,
        dre = /(^([\w ]+,?[\w ]+)?[\w ]+,?[\w ]+\d+:\d+(:\d+)?[\w ]?|^\d{1,4}[\/\-]\d{1,4}[\/\-]\d{1,4}|^\w+, \w+ \d+, \d{4})/,
        hre = /^0x[0-9a-f]+$/i,
        ore = /^0/,
        // convert all to strings and trim()
        x = a.toString().replace(sre, '') || '',
        y = b.toString().replace(sre, '') || '',
        // chunk/tokenize
        xN = x.replace(re, '\0$1\0').replace(/\0$/,'').replace(/^\0/,'').split('\0'),
        yN = y.replace(re, '\0$1\0').replace(/\0$/,'').replace(/^\0/,'').split('\0'),
        // numeric, hex or date detection
        xD = parseInt(x.match(hre), 10) || (xN.length !== 1 && x.match(dre) && Date.parse(x)),
        yD = parseInt(y.match(hre), 10) || xD && y.match(dre) && Date.parse(y) || null;

    // first try and sort Hex codes or Dates
    if (yD) {
        if ( xD < yD ) {
            return -1;
        }
        else if ( xD > yD ) {
            return 1;
        }
    }

    // natural sorting through split numeric strings and default strings
    for(var cLoc=0, numS=Math.max(xN.length, yN.length); cLoc < numS; cLoc++) {
        // find floats not starting with '0', string or 0 if not defined (Clint Priest)
        var oFxNcL = !(xN[cLoc] || '').match(ore) && parseFloat(xN[cLoc], 10) || xN[cLoc] || 0;
        var oFyNcL = !(yN[cLoc] || '').match(ore) && parseFloat(yN[cLoc], 10) || yN[cLoc] || 0;
        // handle numeric vs string comparison - number < string - (Kyle Adams)
        if (isNaN(oFxNcL) !== isNaN(oFyNcL)) {
            return (isNaN(oFxNcL)) ? 1 : -1;
        }
        // rely on string comparison if different types - i.e. '02' < 2 != '02' < '2'
        else if (typeof oFxNcL !== typeof oFyNcL) {
            oFxNcL += '';
            oFyNcL += '';
        }
        if (oFxNcL < oFyNcL) {
            return -1;
        }
        if (oFxNcL > oFyNcL) {
            return 1;
        }
    }
    return 0;
}

jQuery.extend( jQuery.fn.dataTableExt.oSort, {
    "natural-asc": function ( a, b ) {
        return naturalSort(a,b);
    },

    "natural-desc": function ( a, b ) {
        return naturalSort(a,b) * -1;
    }
} );

}());