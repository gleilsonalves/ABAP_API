CLASS zcl_http_request DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.

    CLASS-METHODS class_constructor .
    METHODS request_get
      IMPORTING
        VALUE(is_request)  TYPE zmy_request
      EXPORTING
        VALUE(rs_response) TYPE zmy_response .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_http_request IMPLEMENTATION.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Static Public Method ZCL_HTTP_REQUEST=>CLASS_CONSTRUCTOR
* +-------------------------------------------------------------------------------------------------+
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD class_constructor.

  ENDMETHOD.


* <SIGNATURE>---------------------------------------------------------------------------------------+
* | Instance Public Method ZCL_HTTP_REQUEST->REQUEST_GET
* +-------------------------------------------------------------------------------------------------+
* | [--->] IS_REQUEST                     TYPE        ZMY_REQUEST
* | [<---] RS_RESPONSE                    TYPE        ZMY_RESPONSE
* +--------------------------------------------------------------------------------------</SIGNATURE>
  METHOD request_get.

    DATA: ld_url         TYPE string,
          lo_http_client TYPE REF TO if_http_client,
          ls_header      LIKE LINE OF is_request-header.

    CLEAR: rs_response.

    ld_url = is_request-url.

    CALL METHOD cl_http_client=>create_by_url
      EXPORTING
        url                = ld_url
      IMPORTING
        client             = lo_http_client
      EXCEPTIONS
        argument_not_found = 1
        plugin_not_active  = 2
        internal_error     = 3
        OTHERS             = 4.

    IF is_request-method IS INITIAL OR is_request-method <> 'GET'.
      is_request-method = 'GET'.
    ENDIF.

    CALL METHOD lo_http_client->request->set_method( is_request-method ).

    ls_header-name  = 'Content-Type'.
    ls_header-value = 'application/json'.

    CALL METHOD lo_http_client->request->set_header_field
      EXPORTING
        name  = ls_header-name
        value = ls_header-value.

    CALL METHOD lo_http_client->send
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2.

    CALL METHOD lo_http_client->receive
      EXCEPTIONS
        http_communication_failure = 1
        http_invalid_state         = 2
        http_processing_failed     = 3.

    CALL METHOD lo_http_client->response->get_cdata
      RECEIVING
        data = rs_response-body.

    CALL METHOD lo_http_client->response->get_header_fields
      CHANGING
        fields = rs_response-header.

    CALL METHOD lo_http_client->close
      EXCEPTIONS
        http_invalid_state = 1
        OTHERS             = 2.

  ENDMETHOD.
ENDCLASS.
