////////////////////////////////////////////////////////////////////////////////
// XML
//
// The XML package allows XML DOM traversal and manipulation using XPaths
// in a cross-browser manner
//
// Usage Note:
// If your application needs to generate a pretty HTML representation of the XML
// data, define a variable named XML.htmlFormatter as the XSL sylesheet
// to be used to format the XML.
// For example:
// XML.htmlFormatter = XSLT("xsl/xmlverbatim.xsl");
//
// author: Steven Pothoven
//
////////////////////////////////////////////////////////////////////////////////

if(typeof Prototype=='undefined') {
    throw("XML/XSLT requires the Prototype JavaScript framework >= 1.6.0");
}

// define Douglas Crockford's object function for correct
// JavaScript prototypal inheritance
// see http://javascript.crockford.com/prototypal.html
// We don't use the prototype.js Object implementation because
// it makes a copy of the object being extended.  This implentation
// actually implements inheritance so that inherited functions and
// attributes are visible to the subclass (object), but not copied.
function object(o) {
    function F() {}
    F.prototype = o;
    return new F();
}



/**
 * XML
 * Enhance and standardize XML functions across browsers
 *
 * @param {Object|String|null} xmlDom
 *                             If a DOM object is passed it it is used
 *                             If a String is passed it, it is assumed to be XML data
 *                             If null/undefined, then construct an empty DOM
 */
XML = function(xmlDom) {
    //
    // private data
    //

    var version = '1.0';
    var that;
    var baseDom;
    var parser;

    switch (typeof xmlDom) {
        case 'object':
            // a DOM object was passed in
            baseDom = xmlDom;
            break;
        case 'string':
            // a string of XML data was passed in
            if (Prototype.Browser.IE) {
                Try.these (
                    function() { baseDom = new ActiveXObject("MSXML2.DOMDocument.5.0"); },
                    function() { baseDom = new ActiveXObject("MSXML2.DOMDocument.4.0"); },
                    function() { baseDom = new ActiveXObject("MSXML2.DOMDocument.3.0"); },
                    function() { baseDom = new ActiveXObject("MSXML2.DOMDocument"); },
                    function() { baseDom = new ActiveXObject("Microsoft.XmlDom"); }
                );
                baseDom.async = false;
                   baseDom.loadXML(xmlDom);
            } else {
                   parser = new DOMParser();
                   baseDom = parser.parseFromString(xmlDom,"text/xml");
            }
            break;
        default:
            // nothing was passed in
            // create an empty document
            if (Prototype.Browser.IE) {
                Try.these (
                    function() { baseDom = new ActiveXObject("MSXML2.DOMDocument.5.0"); },
                    function() { baseDom = new ActiveXObject("MSXML2.DOMDocument.4.0"); },
                    function() { baseDom = new ActiveXObject("MSXML2.DOMDocument.3.0"); },
                    function() { baseDom = new ActiveXObject("MSXML2.DOMDocument"); },
                    function() { baseDom = new ActiveXObject("Microsoft.XmlDom"); }
                );
            } else {
                baseDom = document.implementation.createDocument("", "", null);
            }
            // we will most likely invoke the load() function later,
            // so pre-set the DOM to synchronous
            baseDom.async = false;
            break;
    }
    that = object(baseDom);

    //
    // Note: IE doesn't really support DOMDocument objects in JavaScript, but they are
    // ActiveX objects which you cannot inherit from so the call to object() above doesn't
    // really do anything.
    // Therefore, the IE versions of these functions will use baseDom to access the DOMDocument
    // and we need to add a few additional methods to provide access to otherwise inherited data
    //

    //
    // public data
    //

    if (Prototype.Browser.IE) {
        /**
         * load
         * Since IE can't actually do the inheritence, it can't see the load function
         * so make it available for IE
         *
         * @param (String) URL to load
         */
         that.load = function(URL) {
             baseDom.load(URL);
         };

         /**
          * getDOM
          * Since IE can't actually do the inheritence, this object isn't the DOM object,
          * so for other objects that need access to the DOM object (most notably XSLT),
          * we need a way to access it.
          */
          that.getDOM = function() {
              return baseDom;
          };
    }


    /**
     * getNode
     * get a single node from the XML DOM using the XPath
     *
     * @param {String} xpath
     */
    that.getNode = function(xpath) {
        var result;
        var evaluator = this;

        if (Prototype.Browser.IE) {
            result = baseDom.selectSingleNode(xpath);
        } else {
            if (typeof XPathEvaluator !== 'undefined') {
                evaluator = new XPathEvaluator();
            }
            result = evaluator.evaluate(xpath, this, null, XPathResult.FIRST_ORDERED_NODE_TYPE, null);
        }
        return result || null;
    };

    /**
     * getNodeValue
     *
     * @param {String} xpath
     */
    that.getNodeValue = function(xpath) {
        var value, node;
        try {
            node = this.getNode(xpath);

            if (Prototype.Browser.IE && node) {
                value = node.text;
            } else if (node.singleNodeValue) {
                value = node.singleNodeValue.textContent;
            }
        } catch (e) {
            console.error(e);
        }

        return value || null;
    };

    /**
     * getNodes
     * get a multiple nodes from the XML DOM using the XPath
     *
     * @param {String} xpath
     */
    that.getNodes = function(xpath) {
        var nodes = [];
        var result, aNode, i;
        var evaluator = this;

        if (Prototype.Browser.IE) {
            result = baseDom.selectNodes(xpath);
            for (i = 0; i < result.length; i++) {
                aNode = result[i];
                nodes.push(aNode);
            }
        } else {
            if (typeof XPathEvaluator !== 'undefined') {
                evaluator = new XPathEvaluator();
            }
            result = evaluator.evaluate(xpath, this, null, XPathResult.ORDERED_NODE_ITERATOR_TYPE, null);
            while ((aNode = result.iterateNext()) !== null) {
                 nodes.push(aNode);
            }
        }
        return nodes;
    };

    /**
     * getNodeValues
     * get the values of the elements specified by the XPath in the XML DOM
     *
     * @param {String} xpath
     */
    that.getNodeValues = function(xpath) {
        var values = [];
        var nodes, value, i, node;
        try {
            nodes = this.getNodes(xpath);

            value = null;
            for (i = 0; i < nodes.length; i++) {
                node = nodes[i];

                if (Prototype.Browser.IE && node) {
                    value = node.text;
                } else if (node) {
                    value = node.firstChild.nodeValue;
                }
                values.push(value);
            }
        } catch (e) {}

        return values;
    };

    /**
     * countNodes
     * returns number of nodes matching an xpath
     *
     * @param {Object} xpath
     */
    that.countNodes = function(xpath) {
        var values = this.getNodeValues(xpath);
        return values.length;
    };

    /**
     * getNodeAsXml
     * get the XML contents of a node specified by the XPath
     *
     * @param {String} xpath
     */
    that.getNodeAsXml = function(xpath) {
        var str, serializer;
        var aNode = this.getNode(xpath);
        try {
            if (Prototype.Browser.IE) {
                str = aNode.xml;
            } else {
                serializer = new XMLSerializer();
                str = serializer.serializeToString(aNode.singleNodeValue);
            }
        } catch (e) {
            str = "ERROR: No such node in XML";
        }
        return str || null;
    };


    /**
     * toHTML
     * Transform the XML into formatted HTML
     */
    that.toHTML = function() {
        var html;
        if (XML.htmlFormatter) {
            html = XML.htmlFormatter.transform(this);
        } else {
            html = this.getNodeAsXml('/');
            if (html) {
                html = html.replace(/&/g, "&amp;");
                html = html.replace(/</g, "&lt;");
                html = html.replace(/>/g, "&gt;<br/>");
            }
        }
        return html || null;
    };

    /**
     * updateNodeValue
     * update a specific element value in the XML DOM
     *
     * @param {String} xpath
     * @param {String} newvalue
     */
    that.updateNodeValue = function(xpath, newvalue) {
        var node = this.getNode(xpath);
        var changeMade = false;
        newvalue = newvalue.strip();

        if (Prototype.Browser.IE && node) {
            if (node.text != newvalue) {
                node.text = newvalue;
                changeMade = true;
            }
        } else if (node && node.singleNodeValue) {
            if (node.singleNodeValue.textContent != newvalue) {
                node.singleNodeValue.textContent = newvalue;
                changeMade = true;
            }
        } else {
            if (newvalue.length > 0) {
                this.insertNode(xpath);
                changeMade = this.updateNodeValue(xpath, newvalue);
            }
        }

        return changeMade;
    };

    /**
     * insertNode
     * insert a new element (node) into the XML document based on the XPath
     *
     * @param {String} xpath
     */
    that.insertNode = function(xpath) {
        var xpathComponents = xpath.split("/");
        var newChildName = xpathComponents.last();
        var parentPath = xpath.substr(0, xpath.length - newChildName.length - 1);
        var qualifierLoc = newChildName.indexOf("[");
        var parentNode;
        var node = this.getNode(parentPath);
        var newChild = null;

        // remove qualifier for node being added
        if (qualifierLoc != -1) {
            newChildName = newChildName.substr(0, qualifierLoc);
        }
        if (Prototype.Browser.IE && node)    {
            newChild = baseDom.createElement(newChildName);
            node.appendChild(newChild);
        } else if (node && node.singleNodeValue) {
            newChild = this.createElement(newChildName);
            node.singleNodeValue.appendChild(newChild);
        } else {
            // add the parent, then re-try to add this child
            parentNode = this.insertNode(parentPath);
            newChild = this.createElement(newChildName);
            parentNode.appendChild(newChild);
        }
        return newChild;
    };

    /**
     * removeNode
     * remove an element (node) from the XML document based on the xpath
     *
     * @param {String} xpath
     */
    that.removeNode = function(xpath) {
        var node = this.getNode(xpath);
        var changed = false;
        if (Prototype.Browser.IE && node)    {
            node.parentNode.removeChild(node);
            changed = true;
        } else if (node && node.singleNodeValue) {
            node.singleNodeValue.parentNode.removeChild(node.singleNodeValue);
            changed = true;
        }
        return changed;
    };

    return that;
};


////////////////////////////////////////////////////////////////////////////////
// XSLT
//
// The XSLT package allows XSL Transformations in a cross-browser manner
//
// Note: it is included in the srmCommon.js file to as it is used by all SRM
// applications and this minimized the number of separate JS files necessary
// to add to each HTML file and make separate connections to fetch.
//
// author: Steven Pothoven
//
////////////////////////////////////////////////////////////////////////////////


// If this browser does not support an XSLT Processor (and it's not IE which has
// another method), then use Google's JavaScript XSLT processor
if ((!Prototype.Browser.IE) && !(XSLTProcessor)) {
    document.write('<script src="/javascripts/ajaxslt/util.js" type="text/javascript"><\/script>');
    document.write('<script src="/javascripts/ajaxslt/xmltoken.js" type="text/javascript"><\/script>');
    document.write('<script src="/javascripts/ajaxslt/dom.js" type="text/javascript"><\/script>');
    document.write('<script src="/javascripts/ajaxslt/xpath.js" type="text/javascript"><\/script>');
    document.write('<script src="/javascripts/ajaxslt/xslt.js" type="text/javascript"><\/script>');
}

/**
 * XSLT
 * Enhance and standardize XSLT functions across browsers
 *
 * @param {String} xslUrl location of XSLT file
 */
XSLT = function(xslUrl) {
    var that, basicXSLTProcessor, xslDom, strErrMsg, xslTemplate, xslAjax;

    if (window.ActiveXObject) {
        // Internet Explorer with ActiveX enabled
        xslDom = new ActiveXObject("Msxml2.FreeThreadedDOMDocument");
        xslDom.async = false;
        xslDom.load(xslUrl);
        if (xslDom.parseError.errorCode !== 0) {
            strErrMsg = "Problem Parsing Style Sheet:\n" +
                            " Error #: " + xslDom.parseError.errorCode + "\n" +
                            " Description: " + xslDom.parseError.reason + "\n" +
                            " In file: " + xslDom.parseError.url + "\n" +
                            " Line #: " + xslDom.parseError.line + "\n" +
                            " Character # in line: " + xslDom.parseError.linepos + "\n" +
                            " Character # in file: " + xslDom.parseError.filepos + "\n" +
                            " Source line: " + xslDom.parseError.srcText;
            alert(strErrMsg);
            return false;
        }
        xslTemplate = new ActiveXObject("Msxml2.XSLTemplate");
        xslTemplate.stylesheet = xslDom;
        basicXSLTProcessor = xslTemplate.createProcessor();
    } else if(XSLTProcessor) {
        // W3C standard browser
        //xslDom = document.implementation.createDocument("", "", null);
        //xslDom.async = false;
        //alert(xslDom);
        //xslDom.load(xslUrl);
        //alert('loaded XSL');

        var xslDom;
        new Ajax.Request(xslUrl,
        {   method: 'get', asynchronous: false,
            onSuccess: function(t)
            {   xslDom = new XML(t.responseXML);
            }
        });
        basicXSLTProcessor = new XSLTProcessor();
        try { basicXSLTProcessor.importStylesheet(xslDom); } catch(e) { alert(e); raise; }
    } else {
        // IE without ActiveX, Safari, or some other browser that does
        // not supply XSLT support.  Use Google's JavaScript XSLT
        xslAjax = new Ajax.Request(xslUrl,
                        { asynchronous: false,
                          onComplete: function(request) {basicXSLTProcessor = xmlParse(request.responseText);}.bind(this) });
    }
    that = object(basicXSLTProcessor);

    //
    // Note: Just as in XML above, IE doesn't really support a XSLTProcessors object in JavaScript,
    // but they are ActiveX objects which you cannot truely inherit it from so the call to object()
    // above doesn't really do anything.
    // Therefore, the IE versions of these functions will use basebasicXSLTProcessorDom to access the
    // XSLTProcessor
    //


    //
    // public method
    //
    /**
     * transform
     * Transform an XML document
     *
     * @param {Object} xml
     * @param {Object} params
     */
    that.transform = function(xml, params) {
        var myContext, resultDOM, serializer, output, ret;

        // set stylesheet parameters
        for (var param in params) {
            if ((typeof params[param] === 'string') ||
                (typeof params[param] === 'boolean')) {
                try {
                    if (window.ActiveXObject) {
                        basicXSLTProcessor.addParameter(param, params[param]);
                    } else if(XSLTProcessor) {
                        this.setParameter(null, param, params[param] || '');
                    } else {
                        if (!myContext) {
                            myContext = new ExprContext(xml.getNodeAsXml('/'));
                        }
                        myContext.setVariable(param, new StringValue(params[param]));
                    }
                } catch (e) {
                   console.error("Could not set parameter ", param, " to ", params[param], "\n", e);
                }
            }
        }

        try {
            if (window.ActiveXObject) {
                basicXSLTProcessor.input = xml.getDOM();
                basicXSLTProcessor.transform();
                output = basicXSLTProcessor.output;
            } else if (XSLTProcessor) {
                alert('transformToDocument');
                alert(this.transformToDocument);
                try { resultDOM = this.transformToDocument(xml); } catch(e) { alert(e); raise; }
                alert('transformedToDocument');
                serializer = new XMLSerializer();
                output = serializer.serializeToString(resultDOM);
            } else {
                if (myContext) {
                    ret = domCreateDocumentFragment(new XDocument());
                    xsltProcessContext(myContext, this, ret);
                    ouput = xmlText(ret);
                } else {
                    output = xsltProcess(xmlParse(xml.getNodeAsXml('/')), this);
                }
            }
        } catch (transformException) {
            console.error("Problem transforming XML: ", transformException, "\n  XML contents: ", xml.getNodeAsXml('/'), "\n  XSL used: ", xslUrl);
        }
        return output || null;
    };

    return that;
};
