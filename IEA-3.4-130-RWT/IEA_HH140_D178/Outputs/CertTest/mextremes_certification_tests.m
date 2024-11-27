function mextremes_certification_tests()

  % Run MExtremes for a series of sample settings files.
%
% Syntax is:  mextremes_certification_tests
%
% Example:
%     mextremes_certification_tests
%
% See also MExtremes


   % Delete the old comparison file.  Add a header.

DelFile( 'CertTest.comp' )

fid = fopen( 'CertTest.comp', 'wt' );

if ( fid < 0 )
   beep
   error( '  Could not open "CertTest.comp" for reading.' );
end

DateTime = clock;
Date     = date;

fprintf( fid, '\nThis certification comparison was generated on %s at %02d:%02d:%02d.\n', Date, uint8( DateTime(4:6) ) );

fclose( fid );


fprintf( '\n=======\nTest_01\n=======\n' );
MExtremes( 'Test_01.mext' );
FileComp( 'Test_01.extr', 'NREL_Results\Test_01.extr', 5, 'CertTest.comp' )


fprintf( '\n=======\nTest_02\n=======\n' );
MExtremes( 'Test_02.mext' );
FileComp( 'Test_02.extr', 'NREL_Results\Test_02.extr', 5, 'CertTest.comp' )

fprintf( '\n=======\nTest_03\n=======\n' );
MExtremes( 'Test_03.mext' );
FileComp( 'Test_03.extr', 'NREL_Results\Test_03.extr', 5, 'CertTest.comp' )

fprintf( '\n=======\nTest_04\n=======\n' );
MExtremes( 'Test_04.mext' );
FileComp( 'Test_04.extr', 'NREL_Results\Test_04.extr', 5, 'CertTest.comp' )

fprintf( '\n=======\nTest_05\n=======\n' );
MExtremes( 'Test_05.mext' );
FileComp( 'Test_05.extr', 'NREL_Results\Test_05.extr', 5, 'CertTest.comp' )

fprintf( '\n=======\nTest_06\n=======\n' );
MExtremes( 'Test_06.mext' );
FileComp( 'Test_06.extr', 'NREL_Results\Test_06.extr', 5, 'CertTest.comp' )

fprintf( '\n=======\nTest_08\n=======\n' );
MExtremes( 'Test_08.mext' );
FileComp( 'Test_08.extr', 'NREL_Results\Test_08.extr', 5, 'CertTest.comp' )

fprintf( '\n=======\nTest_09\n=======\n' );
MExtremes( 'Test_09.mext' );
FileComp( 'Test_09.extr', 'NREL_Results\Test_09.extr', 5, 'CertTest.comp' )
edit( 'CertTest.comp' )

fprintf( '\n=======\nTest_10\n=======\n' );
MExtremes( 'Test_10.mext' );
FileComp( 'Test_10.extr', 'NREL_Results\Test_10.extr', 5, 'CertTest.comp' )
edit( 'CertTest.comp' )

fprintf( '\n=======\nTest_11\n=======\n' );
MExtremes( 'Test_11.mext' );
FileComp( 'Test_11.extr', 'NREL_Results\Test_11.extr', 5, 'CertTest.comp' )
edit( 'CertTest.comp' )

fprintf( '\n=======\nTest_12\n=======\n' );
MExtremes( 'Test_12.mext' );


fprintf( '\n=======\nTest_13\n=======\n' );
MExtremes( 'Test_13.mext' );
FileComp( 'Test_13.extr', 'NREL_Results\Test_13.extr', 5, 'CertTest.comp' )
edit( 'CertTest.comp' )

fprintf( '\n=======\nTest_14\n=======\n' );
MExtremes( 'Test_14.mext' );


fprintf( '\n=======\nTest_15\n=======\n' );
MExtremes( 'Test_15.mext' );
FileComp( 'Test_15.extr', 'NREL_Results\Test_15.extr', 5, 'CertTest.comp' )
edit( 'CertTest.comp' )

fprintf( '\n=======\nTest_16\n=======\n' );
MExtremes( 'Test_16.mext' );
FileComp( 'Test_16.extr', 'NREL_Results\Test_16.extr', 5, 'CertTest.comp' )
edit( 'CertTest.comp' )

% Test error handling in presence of invalid table name character
fprintf( '\n=======\nTest_07\n=======\n' );
fprintf('This test will intentially generate an error message, due to invalid characters in the table name.\n');
try
   MExtremes('Test_07.mext'); 
catch err
   fprintf( '  Test Successful:  Error was triggered due to invalid character in table name.' );
end  
beep;
   
end