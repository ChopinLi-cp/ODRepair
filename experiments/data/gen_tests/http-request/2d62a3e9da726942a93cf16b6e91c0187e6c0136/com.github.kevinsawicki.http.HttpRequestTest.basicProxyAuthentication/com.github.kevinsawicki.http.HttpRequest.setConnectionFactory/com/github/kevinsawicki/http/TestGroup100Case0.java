package com.github.kevinsawicki.http;

import org.junit.FixMethodOrder;
import org.junit.Test;
import org.junit.runners.MethodSorters;

@FixMethodOrder(MethodSorters.NAME_ASCENDING)
public class TestGroup100Case0 {

    public static boolean debug = false;

    @Test
    public void test1() throws Throwable {
        if (debug)
            System.out.format("%n%s%n", "TestGroup100Case0.test1");
        com.github.kevinsawicki.http.HttpRequest.ConnectionFactory connectionFactory0 = null;
        com.github.kevinsawicki.http.HttpRequest.setConnectionFactory(connectionFactory0);
    }
}

