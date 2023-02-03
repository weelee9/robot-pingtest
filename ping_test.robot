*** Settings ***
Library    PingLibrary.py
Library    OperatingSystem
Library    String

*** Test Cases ***
Given host is reachable
    Ping and Process Response    address=8.8.8.8    num packets=1

Loss within acceptable threshold
    Compare Loss with Threshold

Average ping within acceptable threshold
    Compare Average Ping with Threshold

Connection to given host is good
    Loss and Ping Within Acceptable Thresholds    address=1.1.1.1    num packets=1

Connection to multiple given hosts is good
    [Template]    Loss and Ping Within Acceptable Thresholds
    address=1.0.0.1    num packets=1
    address=8.8.4.4    num packets=1
    address=1.1.1.2    num packets=1
    address=1.0.0.2    num packets=1

Connection to multiple given hosts is good (text file)
    ${contents} =     Get File    hosts.txt
    @{addresses} =    Split To Lines    ${contents}

    FOR    ${address}    IN    @{addresses}
        Log    ${address}
        Loss and Ping Within Acceptable Thresholds    address=${address}    num packets=1
    END

There exists a connection to a host (text file)
    Reset Values
    ${contents} =     Get File    badhosts.txt
    @{addresses} =    Split To Lines    ${contents}
    ${num addresses} =    Get Length    ${addresses}
    ${index}    Set Variable    0

    WHILE    ${index} < ${num addresses}
        TRY
            Ping and Process Response    ${addresses}[${index}]    1
        EXCEPT    Host ${addresses}[${index}] unreachable.
            No Operation
        END

        IF    ${RECEIVED} > 0
            Pass Execution    Found a connection to host ${addresses}[${index}].    
        END
        
        ${index} =     Evaluate    ${index} + 1
    END

    Fail    Could not find a connection to any host.

*** Keywords ***
Ping and Process Response
    [Arguments]    ${address}    ${num packets}
    ${response} =    Ping Address    ${address}    ${num packets}
    Process Response    ${response}
    
Process Response
    [Arguments]    ${response}
    Set Global Variable    ${LOSS}        ${response}[loss]
    Set Global Variable    ${AVG PING}    ${response}[avg_ping]
    Set Global Variable    ${SENT}        ${response}[sent]
    Set Global Variable    ${RECEIVED}    ${response}[rcvd]
    Set Global Variable    ${LOST}        ${response}[lost]

Reset Values
    Set Global Variable    ${LOSS}        0
    Set Global Variable    ${AVG PING}    0
    Set Global Variable    ${SENT}        0
    Set Global Variable    ${RECEIVED}    0
    Set Global Variable    ${LOST}        0

Compare Loss with Threshold
    Log    Sent \= ${SENT}, Received \= ${RECEIVED}, Lost \= ${LOST}, Packet Loss \= ${LOSS}%

    IF    ${LOSS} > ${MAX LOSS}
        Fail    ${LOSS}% loss is above ${MAX LOSS}% threshold.
    END

Compare Average Ping with Threshold
    Log    Average ping over ${RECEIVED}/${SENT} packets is ${AVG PING}ms

    IF    ${AVG PING} > ${MAX AVG PING}
        Fail    ${AVG PING}ms is above ${MAX AVG PING}ms threshold.
    END

Loss and Ping Within Acceptable Thresholds
    [Arguments]    ${address}    ${num packets}
    Ping and Process Response    ${address}    ${num packets}
    Compare Average Ping with Threshold
    Compare Loss with Threshold

*** Variables ***
${MAX AVG PING}    50
${MAX LOSS}        2

${SENT}        0
${RECEIVED}    0
${LOST}        0
${LOSS}        0
${AVG PING}    0