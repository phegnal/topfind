require 'net/http'
require 'rexml/document'

# file as string
file = File.open("inparanoid.xml", "rb")
contents = file.read

# extract event information
doc = REXML::Document.new(contents)

hs = {}
mm = {}

doc.elements.each('orthoXML/species'){|s| 
  p s.attributes["name"]
  x = {}
  s.elements.each("database"){|db| 
    p db.attributes["name"]
    if db.attributes["name"] == "UniProt"
      db.elements.each("genes/gene"){|g|
        x[g.attributes["id"]] = g.attributes["protId"]
      }
    end
  }
  if s.attributes["name"] == "Homo sapiens "
    hs = x
  elsif s.attributes["name"] == "Mus musculus "
    mm = x
  end
}

groupHashes = []
doc.elements.each('orthoXML/groups/orthologGroup'){|group|
  gH = {:mm => [], :hs => []}
  group.elements.each("geneRef"){|r|
      id = r.attributes["id"]
      if hs.keys.include? id
        gH[:hs] << hs[id]
      elsif mm.keys.include? id
        gH[:mm] << mm[id]
      else
      end
  }
  groupHashes << gH
}

p groupHashes

f = File.open("paranoid_output.txt", "w")
f << "Human\tMouse\n"
groupHashes.each{|hash|
  hash[:hs].each{|human|
    hash[:mm].each{|mouse|
      f << "#{human}\t#{mouse}\n"
    }
  }
}
f.close

p "done"