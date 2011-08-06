package com.topdish.activity;

import android.app.Activity;
import android.os.Bundle;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.ViewGroup.LayoutParams;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.ScrollView;
import android.widget.Spinner;
import android.widget.Toast;

public class RateDishActivity extends Activity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		final ScrollView sc = new ScrollView(this);
		final LinearLayout ll = new LinearLayout(this);
		ll.setOrientation(LinearLayout.VERTICAL);

		/*
		 * Add Restaurant Name EditText
		 */
		final EditText restNameTv = new EditText(this);
		restNameTv.setText("Restaurant Name");
		restNameTv.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				restNameTv.setText("");

			}
		});
		restNameTv.setOnFocusChangeListener(new OnFocusChangeListener() {

			@Override
			public void onFocusChange(View v, boolean hasFocus) {
				if (!hasFocus) {
					final EditText et = ((EditText) v);
					if (et.getText().toString().length() == 0)
						et.setText("Restaurant Name");
				}

			}
		});

		ll.addView(restNameTv,
				new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));

		/*
		 * Add Restaurant Name EditText
		 */
		final EditText dishNameTv = new EditText(this);
		dishNameTv.setText("Dish Name");
		dishNameTv.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				dishNameTv.setText("");

			}
		});

		ll.addView(dishNameTv,
				new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));

		final LinearLayout iconsLL = new LinearLayout(this);
		iconsLL.setOrientation(LinearLayout.HORIZONTAL);

		final ImageView up = new ImageView(this);
		up.setImageDrawable(getResources().getDrawable(android.R.drawable.btn_plus));

		iconsLL.addView(up, new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));

		final ImageView down = new ImageView(this);
		down.setImageDrawable(getResources().getDrawable(android.R.drawable.btn_minus));

		iconsLL.addView(down,
				new LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT));

		final ImageView picture = new ImageView(this);
		picture.setImageDrawable(getResources().getDrawable(android.R.drawable.ic_menu_camera));

		iconsLL.addView(picture, new LayoutParams(LayoutParams.WRAP_CONTENT,
				LayoutParams.WRAP_CONTENT));

		ll.addView(iconsLL, new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));

		final EditText comment = new EditText(this);
		comment.setLines(5);
		comment.setScrollBarStyle(EditText.SCROLLBARS_INSIDE_INSET);
		comment.setText("Enter your comment here.");
		comment.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				comment.setText("");

			}
		});

		ll.addView(comment, new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));

		final LinearLayout optionsLL = new LinearLayout(this);
		optionsLL.setOrientation(LinearLayout.HORIZONTAL);

		final Spinner mealType = new Spinner(this);
		mealType.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item,
				new String[] { "dinner", "lunch" }));
		optionsLL.addView(mealType, new LayoutParams(LayoutParams.WRAP_CONTENT,
				LayoutParams.WRAP_CONTENT));

		final Spinner price = new Spinner(this);
		price.setAdapter(new ArrayAdapter<String>(this, android.R.layout.simple_spinner_item,
				new String[] { "expensive", "cheap" }));
		optionsLL.addView(price, new LayoutParams(LayoutParams.WRAP_CONTENT,
				LayoutParams.WRAP_CONTENT));

		ll
				.addView(optionsLL, new LayoutParams(LayoutParams.FILL_PARENT,
						LayoutParams.WRAP_CONTENT));

		final Button submit = new Button(this);
		submit.setText("Submit Dish");
		submit.setOnClickListener(new OnClickListener() {

			@Override
			public void onClick(View v) {
				Toast.makeText(RateDishActivity.this, "You have Submitted!", Toast.LENGTH_SHORT)
						.show();

			}
		});

		ll.addView(submit, new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.WRAP_CONTENT));
		

//		final SlidingDrawer sd = new SlidingDrawer(this, null);
//		sd.setVisibility(SlidingDrawer.INVISIBLE);
//		
//		final Button blue = new Button(this);
//		blue.setText("Example sliding drawer");
//		blue.setOnClickListener(new OnClickListener() {
//			
//			@Override
//			public void onClick(View v) {
//				sd.setVisibility(SlidingDrawer.VISIBLE);
//				
//			}
//		});
//		
		sc.addView(ll, new LayoutParams(LayoutParams.FILL_PARENT, LayoutParams.FILL_PARENT));

		setContentView(sc);

	}
}
