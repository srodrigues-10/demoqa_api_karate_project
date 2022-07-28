package services.bookstore;

import com.intuit.karate.junit5.Karate;

public class BookstoreRunner {

    @Karate.Test
    Karate testUsers() {
        return Karate.run("bookstore").relativeTo(getClass());
    }

}
