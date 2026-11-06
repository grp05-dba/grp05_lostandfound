package ojt;

/** Run alongside the unchanged owning-group sources; credentials stay outside the repo. */
public final class Smoke {
    public static void main(String[] args) throws Exception {
        Db.init();
        var row = Db.rows("select current_user, current_database()").get(0);
        System.out.println("JDBC session: " + row);
        if (!"grp03_ojt_app".equals(row.get("current_user"))) throw new AssertionError("Unexpected database role");
        String password = System.getenv("OJT_DEMO_PASSWORD");
        if (password == null) throw new IllegalArgumentException("Set OJT_DEMO_PASSWORD locally");
        for (String name : new String[]{"demo_admin", "demo_student", "demo_academic_supervisor", "demo_company_supervisor", "demo_ojt_coordinator"}) {
            User u = Main.login(name, password);
            if (u == null) throw new AssertionError("Login failed: " + name);
            var tabs = Roles.tabs(u);
            System.out.println("PASS " + u.role() + ": login and " + tabs.getTabCount() + " tabs constructed");
        }
        Db.c.close();
        System.out.println("PASS application startup, authentication and initial tab queries; interactive actions not exercised");
    }
}
