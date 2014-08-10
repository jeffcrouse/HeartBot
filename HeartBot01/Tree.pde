

void tree() {
  commands.add( "start drawing" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "prep tree" );
  commands.add( "wait for queue" );
  
  
  
  
  
  commands.add( "pen1 up");
  commands.add( "pen2 up");
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "full speed" );
  commands.add( "goto home" );
  commands.add( "wait for queue" );
  commands.add( "end drawing" );
}


void treePrep() {
  moves.add(new PVector(0.5, 1));
}
