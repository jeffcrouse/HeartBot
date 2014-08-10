




void circles() {

  commands.add( "start drawing" );
  commands.add( "pen1 up" );
  commands.add( "pen2 up" );
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );
  commands.add( "full speed" );


  circleCenter.x = 0.05;
  circleCenter.y = random(0.25, 0.75);
  circleRadius = 0.1;

  for (int i=0; i<8; i++) {

    commands.add( "circles update" );

    commands.add( "circles prep" );
    commands.add( "wait for queue" );

    commands.add( "pen1 down" );
    commands.add( "circle" );
    commands.add( "wait for queue" );

    commands.add( "pen1 up" );
  }

  commands.add( "pen1 up");
  commands.add( "pen2 up");
  commands.add( "pen1 home" );
  commands.add( "pen2 home" );

  commands.add( "full speed" );
  commands.add( "goto home" );
  commands.add( "wait for queue" );
  commands.add( "end drawing" );
}

void circlesPrep() {
  PVector p = new PVector();
  p.x = circleCenter.x + cos(0) * circleRadius;
  p.y = circleCenter.y + sin(0) * circleRadius;
  moves.add(p);
}

void circlesUpdate() {
  circleRadius = random(0.05, 0.09);
  circleCenter.x += circleRadius;
}

