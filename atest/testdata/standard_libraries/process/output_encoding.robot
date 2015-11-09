*** Settings ***
Resource          process_resource.robot
Test Template     Output Encoding Should Work Correctly

*** Test Cases ***
Custom encoding when using default streams
    UTF-8
    Latin-1

Custom encoding when using custom streams
    UTF-8      stdout=${STDOUT}    stderr=${STDERR}
    Latin-1    stdout=${STDOUT}    stderr=${STDERR}

Console encoding
    SYSTEM
    SYSTEM     stdout=${STDOUT}    stderr=${STDERR}

System encoding
    SYSTEM
    SYSTEM     stdout=${STDOUT}    stderr=${STDERR}

Invalid encoding
    [Template]    NONE
    ${result} =    Run Process With Output Encoding    Latin-1    ASCII
    Should Be Equal    ${result.stderr}    hyv\\xe4
    Should Be Equal    ${result.stderr}    hyv\\xe4

*** Keywords ***
Output Encoding Should Work Correctly
    [Arguments]    ${encoding}    ${stdout}=${NONE}    ${stderr}=${NONE}
    ${result} =    Run Process With Output Encoding    ${encoding}
    ...    stdout=${stdout}    stderr=${stderr}
    Should Be Equal    ${result.stderr}    hyvä
    Should Be Equal    ${result.stdout}    hyvä

Run Process With Output Encoding
    [Arguments]    ${encoding}    ${output_encoding}=${NONE}
    ...    ${stdout}=${NONE}    ${stderr}=${NONE}
    ${code} =    Catenate    SEPARATOR=;
    ...    import sys
    ...    from robot.utils.encoding import OUTPUT_ENCODING, SYSTEM_ENCODING
    ...    py2 = sys.version_info[0] < 3
    ...    encoding = '${encoding}'
    ...    encoding = {'CONSOLE': OUTPUT_ENCODING, 'SYSTEM': SYSTEM_ENCODING}.get(encoding, encoding)
    ...    output = u'hyv\\xe4'.encode(encoding)
    ...    (sys.stdout if py2 else sys.stdout.buffer).write(output)
    ...    (sys.stderr if py2 else sys.stderr.buffer).write(output)
    ${output_encoding} =    Evaluate    $output_encoding or $encoding
    ${result} =    Run Process    python    -c    ${code}
    ...    stdout=${stdout}    stderr=${stderr}    output_encoding=${output encoding}
    [Return]    ${result}