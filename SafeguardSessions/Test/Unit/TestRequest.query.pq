section TestRequest;

Request = Extension.ImportModule("Request.pqm");

Request.GetAuthParameters = Request[GetAuthParameters];
Request.GetDefaultParameters = Request[GetDefaultParameters];
Request.Generate = Request[Generate];

TestRequestGeneration = () =>
    let
        fakeresponse = FakeRawResponse([dummy_field = "value", dummy_list = {0, 1, 2}]),
        expected_body = [dummy_field = "value", dummy_list = {0, 1, 2}],
        expected_meta = [Content.Type = "application/json", Response.Status = 200, RequestUrl = "dummy_url"],
        response = Request.Generate("dummy_url", [], [Response = fakeresponse]),
        facts = {
            Fact("Response body as json is correct", expected_body, response),
            Fact("Response meta is correct", expected_meta, Value.Metadata(response))
        }
    in
        facts;

shared TestRequest.UnitTest = [
    facts = {
        Fact(
            "Check authentication request parameters:",
            [
                Query = [return = "/api/authentication", login_method = "local"],
                Headers = [
                    #"Authorization" = "Basic YWxtYTpzemlsdmE=",
                    #"Accept" = "*/*",
                    #"Connection" = "keep-alive",
                    #"Cache-Control" = "no-cache, no-store, must-revalidate"
                ],
                IsRetry = true
            ],
            Request.GetAuthParameters("YWxtYTpzemlsdmE=")
        ),
        Fact(
            "Check default request parameters:",
            [
                Headers = [
                    #"Accept" = "application/json",
                    #"Connection" = "keep-alive",
                    #"Cookie" = "session_id=47710719df1849b5b6aa2fd301e32a216cffe38b"
                ],
                IsRetry = true
            ],
            Request.GetDefaultParameters("session_id=47710719df1849b5b6aa2fd301e32a216cffe38b")
        ),
        TestRequestGeneration()
    },
    report = Facts.Summarize(facts)
][report];
