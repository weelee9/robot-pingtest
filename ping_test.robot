*** Settings ***
Library    PingLibrary.py

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
    1.0.0.1    1
    8.8.4.4    1
    1.1.1.2    1
    1.0.0.2    1

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
${MAX AVG PING}    20
${MAX LOSS}        2

${SENT}
${RECEIVED}
${LOST}
${LOSS}
${AVG PING}