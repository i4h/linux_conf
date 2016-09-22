#!/usr/bin/env python
from optparse import OptionParser
import sys
import csv

def main():
    #Get options and arguments
    parser = parserSetup()
    (options, args) = parser.parse_args()

    if options.optionWriteExample:
        writeExample()
        sys.exit()

    if len(args) != 2:
        parser.error("Two arguments required, run with -h for help")

        
    templateFileName = args[0]
    replacementsFileName = args[1]

    #Run main program

    #Read replacements from file
    values = []
    templateFile = open(templateFileName)
    with open(replacementsFileName, 'r') as csvfile:
        spamreader = csv.reader(csvfile, delimiter=',', quotechar='"')
        first = True
        for row in spamreader:
            if first:
                placeholders = row
                first = False
            else:
                values.append(row)

    #Get outfile if -o was used
    if options.filename != "":
        outfile = open(options.filename, 'w')

    #Perform replacements
    for row in values:
        if len(row) > 0: #Ignore empty lines
            if options.filename == "":
                outFileName = row.pop(0)
                outfile = open(outFileName, 'w')
            else:
                row.pop(0)
            if options.verbose:
                print "Performing replacements for file " + outFileName
            replacements = {}
            #Build a dict with the replacements
            for ph, val in zip(placeholders,row):
                replacements[ph] = val

            if options.verbose:
                print replacements

            templateFile.seek(0) #Rewind iterator to first line of template file
            for templateLine in templateFile:
                outfile.write(templateLine.format(**replacements))

            if options.filename == "":                
                outfile.close()


def parserSetup():
    """Return a configured option parser for this program"""
    description = "Creates copies of the template and performs replacements according " + \
                  "to the replacements file. \n" + \
                  "Call with --write-example to get an example replacements and template file"
    usage = "%prog [options] template replacements.csv"
    parser = OptionParser(description=description,usage=usage)
    parser.add_option("-v", "--verbose",
                      action="store_true", dest="verbose")
    parser.add_option("-q", "--quiet",
                      action="store_false", dest="verbose")
    parser.add_option("-x", "--write-example",
                      action="store_true", dest="optionWriteExample",default=False,
                      help="Creates replacements_example.csv and template_example in working directory for referen#e. Run template_replace.py template_example replacements_example.csv to see results." )
    parser.add_option("-o", "--output", action="store", type="string", dest="filename",default="",
                      help="Write all output to this file, ignore filenames given in replacements file")

    return parser

def writeExample():
    print "Creating replacements_example.csv...",
    replacements = open("replacements_example.csv","w")
    replacements.write("text,value\n")
    replacements.write("out_example1,\"text1\",1\n")
    replacements.write("out_example2,\"text2\",2\n")
    replacements.close()
    print "Done"
    print "Creating template_example...",
    template = open("template_example","w")
    template.write("template {text} = {value}\n")
    template.close()
    print "Done"
    print "To see how this script works, run"
    print "template_replace.py template_example replacements_example.csv"

if __name__ == '__main__':
    main()
