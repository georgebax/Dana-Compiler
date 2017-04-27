def solve
	def hanoi: rings as int, source target auxiliary as byte []
		    def move: source target as byte []
			    writeString: "Moving from "
    			writeString: source	
    			writeString: " to "
    			writeString: target
    			writeString: ".\n"
		var numberOfRings is int
		writeString: "Rings: "				
		numberOfRings := readInteger()
		hanoi: numberOfRings, "left","right","middle"


