/*
 * Description: Banking System for proj01, stateless.
 * 
 * Name: Diego Cruz
 * SID: 013540384
 * 
 * Course: CS 157A
 * Section: 02
 * Homework: proj02
 * Date: 05 December 2022
 */

import java.io.FileInputStream;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.ResultSet;
import java.sql.Statement;
import java.util.Properties;

/**
 * Manage connection to database and perform SQL statements.
 */
public class BankingSystem {
	// Connection properties
	private static String driver;
	private static String url;
	private static String username;
	private static String password;

	// JDBC Objects
	private static Connection con;
	private static Statement stmt;
	private static ResultSet rs;

	/**
	 * Initialize database connection given properties file.
	 * 
	 * @param filename name of properties file
	 */
	public static void init(String filename) {
		try {
			Properties props = new Properties(); // Create a new Properties object
			FileInputStream input = new FileInputStream(filename); // Create a new FileInputStream object using our
																	// filename parameter
			props.load(input); // Load the file contents into the Properties object
			driver = props.getProperty("jdbc.driver"); // Load the driver
			url = props.getProperty("jdbc.url"); // Load the url
			username = props.getProperty("jdbc.username"); // Load the username
			password = props.getProperty("jdbc.password"); // Load the password
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	/**
	 * Test database connection.
	 */
	public static void testConnection() {
		System.out.println(":: TEST - CONNECTING TO DATABASE");
		try {
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			con.close();
			System.out.println(":: TEST - SUCCESSFULLY CONNECTED TO DATABASE");
		} catch (Exception e) {
			System.out.println(":: TEST - FAILED CONNECTED TO DATABASE");
			e.printStackTrace();
		}
	}

	/**
	 * Create a new customer.
	 * 
	 * @param name   customer name
	 * @param gender customer gender
	 * @param age    customer age
	 * @param pin    customer pin
	 */
	public static void newCustomer(String name, String gender, String age, String pin) {
		System.out.println(":: CREATE NEW CUSTOMER - RUNNING");
		try {
			if (!nameIsValid(name))
				throw new TailoredException("INVALID NAME");
			if (!genderIsValid(gender))
				throw new TailoredException("INVALID GENDER");
			if (!ageIsValid(age))
				throw new TailoredException("INVALID AGE");
			if (!pinIsValid(pin))
				throw new TailoredException("INVALID PIN");
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = ("P2.CUST_CRT('%s', '%s', %s, %s, ?, ?, ?)");
			// %s denotes a string concatenation which you can then combine with
			// String.format which then replaces the concatenations with your
			// desired replacements
			stmt.executeUpdate(String.format(query, name, gender, age, pin)); // jdbc statement
			stmt.close();
			con.close();
			System.out.println(":: CREATE NEW CUSTOMER - SUCCESS");
		} catch (TailoredException e) {
			System.out.println("CREATE NEW CUSTOMER - ERROR - " + e.getMessage());
		} catch (Exception e) {
			System.out.println(":: CREATE NEW CUSTOMER - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Login function for use in CLI designed in p1.java
	 * 
	 * @param id The ID value to use in attempted login
	 * @param pin The PIN value to use in attempted login
	 * @return Boolean value for whether login was successful
	 */
	public static boolean login(String id, String pin) {
		System.out.println(":: LOGIN - RUNNING");
		try {
			if (!idIsValid(id))
				throw new TailoredException("INVALID ID");
			if (!pinIsValid(pin))
				throw new TailoredException("INVALID PIN");
			if (!customerExists(id))
				throw new TailoredException("CUSTOMER DOES NOT EXIST");
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "CALL P2.CUST_LOGIN( %s, %s, ?, ?, ?)";
			rs = stmt.executeQuery(String.format(query, id, pin));
			rs.next();
			boolean pinValid = rs.getInt(1) == 1;
			rs.close();
			stmt.close();
			con.close();
			if (!pinValid)
				throw new TailoredException("INCORRECT CREDENTIALS");
			System.out.println(":: LOGIN CUSTOMER - SUCCESS");
			return true;

		} catch (TailoredException e) {
			System.out.println(":: LOGIN - ERROR - " + e.getMessage());
		} catch (Exception e) {
			System.out.println(":: LOGIN - FAILED");
			e.printStackTrace();
		}
		return false;
	}

	/**
	 * Open a new account.
	 * 
	 * @param id     customer id
	 * @param type   type of account
	 * @param amount initial deposit amount
	 */
	public static void openAccount(String id, String type, String amount) {
		System.out.println(":: OPEN ACCOUNT - RUNNING");
		try {
			if (!customerExists(id))
				throw new TailoredException("CUSTOMER DOES NOT EXIST");
			if (!idIsValid(id))
				throw new TailoredException("INVALID CUSTOMER ID");
			if (!typeIsValid(type))
				throw new TailoredException("INVALID TYPE");
			if (!amountIsValid(amount))
				throw new TailoredException("INVALID AMOUNT");

			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "P2.ACCT_OPEN( %s, %s, '%s', ?, ?, ?)";
			stmt.executeQuery(String.format(query, id, amount, type));
			System.out.println(":: OPEN ACCOUNT - SUCCESS");
			stmt.close();
			con.close();
		} catch (TailoredException e) {
			System.out.println(":: OPEN ACCOUNT - ERROR - " + e.getMessage());
		} catch (Exception e) {
			System.out.println(":: OPEN ACCOUNT - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Close an account.
	 * 
	 * @param accNum account number
	 */
	public static void closeAccount(String accNum) {
		System.out.println(":: CLOSE ACCOUNT - RUNNING");
		try {
			if (!accountIsActive(accNum))
				throw new TailoredException("ACCOUNT IS ALREADY CLOSED");
			if (!accNumIsValid(accNum))
				throw new TailoredException("INVALID ACCOUNT NUMBER");
			if (!accountExists(accNum))
				throw new TailoredException("ACCOUNT DOES NOT EXIST");
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "CALL P2.ACCT_CLS(%s, ?, ?)";
			stmt.executeQuery(String.format(query, accNum));
			System.out.println(":: CLOSE ACCOUNT - SUCCESS");
			stmt.close();
			con.close();
		} catch (TailoredException e) {
			System.out.println(":: CLOSE ACCOUNT - ERROR - " + e.getMessage());
		} catch (Exception e) {
			System.out.println(":: CLOSE ACCOUNT - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Deposit into an account.
	 * 
	 * @param accNum account number
	 * @param amount deposit amount
	 */
	public static void deposit(String accNum, String amount) {
		System.out.println(":: DEPOSIT - RUNNING");
		try {
			if (!accNumIsValid(accNum))
				throw new TailoredException("INVALID ACCOUNT NUMBER");
			if (!amountIsValid(amount))
				throw new TailoredException("INVALID AMOUNT");
			if (!accountExists(accNum))
				throw new TailoredException("ACCOUNT DOES NOT EXIST");
			if (!accountIsActive(accNum))
				throw new TailoredException("ACCOUNT IS INACTIVE");
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "CALL P2.ACCT_DEP(%s, %s, ?, ?)";
			stmt.execute(String.format(query, accNum, amount));
			System.out.println(":: DEPOSIT - SUCCESS");
			stmt.close();
			con.close();
		} catch (TailoredException e) {
			System.out.println("DEPOSIT - ERROR - " + e.getMessage());
		} catch (Exception e) {
			System.out.println(":: DEPOSIT - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Withdraw from an account.
	 * 
	 * @param accNum account number
	 * @param amount withdraw amount
	 */
	public static void withdraw(String accNum, String amount) {
		System.out.println(":: WITHDRAW - RUNNING");
		try {
			if (!accNumIsValid(accNum))
				throw new TailoredException("INVALID ACCOUNT NUMBER");
			if (!amountIsValid(amount))
				throw new TailoredException("INVALID AMOUNT");
			if (!accountExists(accNum))
				throw new TailoredException("ACCOUNT DOES NOT EXIST");
			if (!accountIsActive(accNum))
				throw new TailoredException("ACCOUNT IS INACTIVE");
			if (!hasTheFunds(accNum, amount))
				throw new TailoredException("NOT ENOUGH FUNDS");
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "CALL P2.ACCT_WTH(%s, %s, ?, ?)";
			stmt.executeQuery(String.format(query, accNum, amount));
			System.out.println(":: WITHDRAW - SUCCESS");
			stmt.close();
			con.close();
		} catch (TailoredException e) {
			System.out.println(":: WITHDRAW - ERROR - " + e.getMessage());
		} catch (Exception e) {
			System.out.println(":: WITHDRAW - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Transfer amount from source account to destination account.
	 * 
	 * @param srcAccNum  source account number
	 * @param destAccNum destination account number
	 * @param amount     transfer amount
	 */
	public static void transfer(String srcAccNum, String destAccNum, String amount) {
		System.out.println(":: TRANSFER - RUNNING");
		try {
			if (!accNumIsValid(srcAccNum) || !accNumIsValid(destAccNum))
				throw new TailoredException("INVALID ACCOUNT NUMBER");
			if (!amountIsValid(amount))
				throw new TailoredException("INVALID AMOUNT");
			if (!accountExists(srcAccNum) || !accountExists(destAccNum))
				throw new TailoredException("ACCOUNT DOES NOT EXIST");
			if (!accountIsActive(srcAccNum) || !accountIsActive(destAccNum))
				throw new TailoredException("ACCOUNT IS INACTIVE");
			if (!hasTheFunds(srcAccNum, amount))
				throw new TailoredException("NOT ENOUGH FUNDS");
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "CALL P2.ACCT_TRX(%s, %s, %s, ?, ?)";
			stmt.executeQuery(String.format(query, srcAccNum, destAccNum, amount));
			System.out.println(":: WITHDRAW - SUCCESS");
			stmt.close();
			con.close();
			System.out.println(":: TRANSFER - SUCCESS");
		} catch (TailoredException e) {
			System.out.print(":: TRANSFER - ERROR - " + e.getMessage());
		} catch (Exception e) {
			System.out.println(":: TRANSFER - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Display account summary.
	 * 
	 * @param cusID customer ID
	 */
	public static void accountSummary(String cusID) {
		System.out.println(":: ACCOUNT SUMMARY - RUNNING");
		try {
			if (!idIsValid(cusID))
				throw new TailoredException("INVALID CUSTOMER ID");
			if (!customerExists(cusID))
				throw new TailoredException("CUSTOMER DOES NOT EXIST");
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT number, balance FROM p1.account WHERE id = %s AND status = 'A';";
			rs = stmt.executeQuery(String.format(query, cusID));
			int total = 0;
			System.out.println("NUMBER      BALANCE     ");
			System.out.println("----------- ----------- ");
			while (rs.next()) {
				int number = rs.getInt(1);
				int balance = rs.getInt(2);
				total += balance;
				System.out.printf("%11d %11d \n", number, balance);
			}
			System.out.println("----------- ----------- ");
			System.out.printf("TOTAL       %11d \n", total);
			System.out.println(":: ACCOUNT SUMMARY - SUCCESS");
			stmt.close();
			con.close();
		} catch (TailoredException e) {
			System.out.println(":: ACCOUNT SUMMARY - ERROR - " + e.getMessage());
		} catch (Exception e) {
			System.out.println(":: ACCOUNT SUMMARY - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Display Report A - Customer Information with total balance in decreasing  order.
	 */
	public static void reportA() {
		System.out.println(":: REPORT A - RUNNING");
		try {
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT p1.customer.id, name, gender, age, SUM(balance) AS TOTAL " +
					"FROM p1.customer JOIN p1.account ON p1.customer.id = p1.account.id AND p1.account.status = 'A' " +
					"GROUP BY p1.customer.id, name, gender, age ORDER BY TOTAL DESC;";
			rs = stmt.executeQuery(query);
			System.out.println("ID          NAME            GENDER AGE         TOTAL       ");
			System.out.println("----------- --------------- ------ ----------- ----------- ");
			while (rs.next()) {
				int id = rs.getInt(1);
				String name = rs.getString(2);
				String gender = rs.getString(3);
				int age = rs.getInt(4);
				int total = rs.getInt(5);
				System.out.printf("%11d %15s %6s %11d %11d \n", id, name, gender, age, total);
			}
			System.out.println(":: REPORT A - SUCCESS");
			rs.close();
			stmt.close();
			con.close();
		} catch (Exception e) {
			System.out.println(":: REPORT A - FAILED");
			e.printStackTrace();
		}
	}

	/**
	 * Display Report B - Average Total Balance within an age range
	 * 
	 * @param min minimum age
	 * @param max maximum age
	 */
	public static void reportB(String min, String max) {
		System.out.println(":: REPORT B - RUNNING");
		try {
			Class.forName(driver);
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT AVG(TOTAL)  FROM (SELECT p1.customer.id, age, status, " +
					"SUM(balance) as TOTAL FROM p1.customer JOIN p1.account ON p1.customer.id = p1.account.id " +
					"GROUP BY p1.customer.id, age, status) " +
					"WHERE age >= %s AND age <= %s AND status = 'A';";
			rs = stmt.executeQuery(String.format(query, min, max));
			System.out.println("AVERAGE     ");
			System.out.println("----------- ");
			rs.next();
			int average = rs.getInt(1);
			System.out.printf("%11d \n", average);
			System.out.println(":: REPORT B - SUCCESS");
			rs.close();
			stmt.close();
			con.close();
		} catch (Exception e) {
			System.out.println(":: REPORT B - FAILED");
			e.printStackTrace();
		}
	}

	/*
	 * Anything beyond this point will contain validity checks
	 * as well as in-house solutions for catching errors that might not
	 * be communicated from SQL to jdbc
	 */

	/**
	 * A custom exception handling class to outline specific
	 * condition failures.
	 * 
	 * Mainly for internal use
	 * 
	 * @param errMessage Error message string to later be printed to console
	 */
	private static class TailoredException extends Exception {
		public TailoredException(String errMessage) {
			super(errMessage);
		}
	}

	// The following will be validity checks for the p1.customer relation

	/**
	 * Checks if the customer exists using an id
	 * 
	 * @param id The customer id to be referenced
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean customerExists(String id) {
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT id FROM p1.customer WHERE id = %s";
			rs = stmt.executeQuery(String.format(query, id));
			rs.next();
			int retrievedID = rs.getInt(1);
			rs.close();
			stmt.close();
			con.close();
			if (Integer.parseInt(id) == retrievedID) {
				return true;
			} else
				return false;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the customer id is above 0.
	 * 
	 * @param id The id to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean idIsValid(String id) {
		try {
			return Integer.parseInt(id) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the name is a valid string less than or equal to 15 chars
	 * 
	 * @param name The name to be checked.
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean nameIsValid(String name) {
		return name != null && name.length() <= 15;
	}

	/**
	 * Checks if the gender is a valid entry that is either 'M' or 'F'
	 * 
	 * @param gender The gender to be checked.
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean genderIsValid(String gender) {
		return gender.equals("M") || gender.equals("F");
	}

	/**
	 * Checks if the age is above 0.
	 * 
	 * @param age The age to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean ageIsValid(String age) {
		try {
			return Integer.parseInt(age) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the pin code is above 0.
	 * 
	 * @param pin The pin to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean pinIsValid(String pin) {
		try {
			return Integer.parseInt(pin) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

	// The following will be validity checks for the p1.account relation

	/**
	 * Checks if the account exists regardless of activity
	 * 
	 * @param accNum The account number to be referenced
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean accountExists(String accNum) {
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT number FROM p1.account WHERE number = %s";
			rs = stmt.executeQuery(String.format(query, accNum));
			rs.next();
			int retreivedNum = rs.getInt(1);
			if (Integer.parseInt(accNum) == retreivedNum) {
				return true;
			}
			rs.close();
			stmt.close();
			con.close();
			return true;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if there are sufficient funds in a withdrawal or transfer.
	 * 
	 * @param accNum The account number used for the attempted transaction.
	 * @param amount The amount used for the attempted transaction
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean hasTheFunds(String accNum, String amount) {
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT balance from p1.account WHERE number = %s";
			rs = stmt.executeQuery(String.format(query, accNum));
			rs.next();
			int currentBalance = rs.getInt(1);
			rs.close();
			stmt.close();
			con.close();

			if (currentBalance >= Integer.parseInt(amount)) {
				return true;
			}

			else {
				return false;
			}
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the account type is either 'C' for Checking or 'S' for savings
	 * 
	 * @param type The type to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean typeIsValid(String type) {
		return type.equals("C") || type.equals("S");
	}

	/**
	 * Checks if an account is active
	 * 
	 * @param accNum The account number to be referenced
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean accountIsActive(String accNum) {
		try {
			con = DriverManager.getConnection(url, username, password);
			stmt = con.createStatement();
			String query = "SELECT status FROM p1.account WHERE number = %s AND status = 'A'";
			rs = stmt.executeQuery(String.format(query, accNum));
			rs.next();
			String status = rs.getString(1);
			rs.close();
			stmt.close();
			con.close();
			return status.equals("A");
		} catch (Exception e) {
			return false;
		}
	}

	// The following will be validity checks that have more to do with Java compiling
	// than JDBC-SQL

	/**
	 * Checks if an amount is a valid integer for use in Banking System
	 * transactions.
	 * 
	 * @param amount The amount to be checked
	 * @return Boolean value for use in creating TailoredExceptions
	 */
	public static boolean amountIsValid(String amount) {
		try {
			return Integer.parseInt(amount) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

	/**
	 * Checks if the account number is a valid integer for use in Banking System
	 * 
	 * @param accNum The account number to be checked
	 * @return Boolean value for use in creating Tailored Exceptions
	 */
	public static boolean accNumIsValid(String accNum) {
		try {
			return Integer.parseInt(accNum) >= 0;
		} catch (Exception e) {
			return false;
		}
	}

}