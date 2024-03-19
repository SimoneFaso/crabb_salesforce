public with sharing class CSVParser {

	public static List<List<String>> parseCSV(String contents) {
		Boolean skipHeaders = false;
		List<List<String>> allFields = new List<List<String>>();

		final String SEPROW = '\r\n';
		final String SEPROWr = '\r';
		final String SEPROWn = '\n';
		final Integer maxLength = 200000;
		
		List<String> pieces = new List<String>();
		system.debug('*****contents.length() = ' + contents.length());
		if(contents.length()>maxLength){
			Boolean EOF = true;
			while(EOF){
				String wrap = '';
				system.debug('*****contents.length()AA = ' + contents.length());
				if(contents.length()>maxLength){
					wrap = contents.substring(0,maxLength);
					system.debug('****wrap1 = ' + wrap);
				}else{
					wrap = contents;
					system.debug('****wrap2 = ' + wrap);
					EOF = false;
				}
				system.debug('******EOF = ' + EOF);
				pieces.add(EOF ? wrap.substring(0,wrap.lastIndexOf(SEPROW)) : wrap);  
				contents = contents.substring(wrap.lastIndexOf(SEPROW)+2);
			}
		}else
			pieces.add(contents);
		
		for(String piece : pieces){
			// replace instances where a double quote begins a field containing a comma
			// in this case you get a double quote followed by a doubled double quote
			// do this for beginning and end of a field
			
			List<String> lines = new List<String>();
			try{
				lines = piece.split(SEPROW);
			}catch (System.ListException e){
				System.debug('Limits exceeded?' + e.getMessage());
			}
			for(String line : lines){
				system.debug('********line = ' + line);
				line = line.trim();
				line = line.substring(1, line.length()-1);
				system.debug('*******line_2 =  ' + line);
				List<String> fields = line.split('","',-1);
				system.debug('********fields = ' + fields);
				
				allFields.add(fields);
			}
		}
		if(skipHeaders) allFields.remove(0);
		return allFields;
	}
}