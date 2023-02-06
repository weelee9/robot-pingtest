*** Settings ***
Library    PingLibrary.py
Library    OperatingSystem
Library    String

*** Test Cases ***
Given host is reachable
    Ping and Get Statistics    address=8.8.8.8    num packets=1

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
        Append Response To Output
    END

    Write Output To Json    good-connection-multiple-hosts.json

There exists a connection to a host (text file)
    Set Global Variable    ${RESPONSE}    ${EMPTY}
    ${contents} =     Get File    badhosts.txt
    @{addresses} =    Split To Lines    ${contents}
    ${num addresses} =    Get Length    ${addresses}
    ${index}    Set Variable    0

    WHILE    ${index} < ${num addresses}
        TRY
            Ping and Get Statistics    ${addresses}[${index}]    1
            Pass Execution    Found a connection to host ${addresses}[${index}].
        EXCEPT    Host ${addresses}[${index}] unreachable.
            No Operation
        END
        
        ${index} =     Evaluate    ${index} + 1
    END

    Fail    Could not find a connection to any host.

*** Keywords ***
Ping and Get Statistics
    [Arguments]    ${address}    ${num packets}
    ${response} =    Ping Address    ${address}    ${num packets}
    Set Global Variable    ${RESPONSE}    ${response}

Compare Loss with Threshold
    Log    Sent \= ${RESPONSE}[sent], Received \= ${RESPONSE}[rcvd], Packet Loss \= ${RESPONSE}[loss]%

    IF    ${RESPONSE}[loss] > ${MAX LOSS}
        Fail    ${RESPONSE}[loss]% loss is above ${MAX LOSS}% threshold.
    END

Compare Average Ping with Threshold
    Log    Average ping over ${RESPONSE}[rcvd]/${RESPONSE}[sent] packets is ${RESPONSE}[avg_ping]ms

    IF    ${RESPONSE}[avg_ping] > ${MAX AVG PING}
        Fail    ${RESPONSE}[avg_ping]ms is above ${MAX AVG PING}ms threshold.
    END

Loss and Ping Within Acceptable Thresholds
    [Arguments]    ${address}    ${num packets}
    Ping and Get Statistics    ${address}    ${num packets}
    Compare Average Ping with Threshold
    Compare Loss with Threshold

*** Variables ***
${MAX AVG PING}    50
${MAX LOSS}        2

${RESPONSE}    ${EMPTY}